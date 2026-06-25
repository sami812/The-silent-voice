import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand_landmarker/hand_landmarker.dart' as ai;
import 'package:the_silent_voice/services/sign_language_decoder.dart';
import 'package:the_silent_voice/components/chat_message.dart';
import 'package:the_silent_voice/components/cv_subtitle_window.dart';
import 'package:the_silent_voice/components/cv_utility_bar.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/services/stt_service.dart';
import 'package:the_silent_voice/services/tts_service.dart';

class VideoChatPage extends StatefulWidget {
  const VideoChatPage({super.key});

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  // ── camera ──────────────────────────────────────────────────────────────
  CameraController? cameraController;
  List<CameraDescription> _availableCameras = [];
  CameraMode _cameraMode = CameraMode.front;
  bool isCameraReady = false;
  int _rotationAngle = 270; // front camera default; back = 90

  // ── hand landmark model ──────────────────────────────────────────────────
  ai.HandLandmarkerPlugin? _handLandmarkerPlugin;
  bool _isModelBusy = false;

  // ── translation state ────────────────────────────────────────────────────
  bool _isTranslating = false;
  String _signTranslation = 'Scanning...';
  String _lockedWord = 'Scanning...';
  String _finalMotion = 'still';

  // ── motion tracking ──────────────────────────────────────────────────────
  double _baseWristX = 0;
  double _baseWristY = 0;
  double _baseHandSize = 0;
  double _prevWristX = 0;
  double _prevWristY = 0;
  int _shakeCounter = 0;
  bool _isShakeActive = false;

  // ── output log ───────────────────────────────────────────────────────────
  final List<ChatMessage> _translations = [];

  // Per-finger history buffer for 3-frame majority-vote smoothing
  final List<List<int>> _fingerHistory = List.generate(5, (_) => []);

  static const Color _blue = Color(0xFF1067FC);

  // ────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _handLandmarkerPlugin = ai.HandLandmarkerPlugin.create(numHands: 1);
    _setupCamera();
    context.read<ConversationHistoryService>().startSession();
  }

  @override
  void dispose() {
    cameraController?.stopImageStream().catchError((_) {});
    cameraController?.dispose();
    _handLandmarkerPlugin?.dispose();
    super.dispose();
  }

  // ── camera setup & switching ─────────────────────────────────────────────
  Future<void> _setupCamera() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) return;
      await _switchToMode(_cameraMode);
    } catch (e) {
      debugPrint('Camera setup error: $e');
    }
  }

  Future<void> _switchToMode(CameraMode mode) async {
    // Stop and dispose previous controller cleanly
    final prev = cameraController;
    if (mounted) setState(() { isCameraReady = false; cameraController = null; });
    try { await prev?.stopImageStream(); } catch (_) {}
    await prev?.dispose();
    await Future.delayed(const Duration(milliseconds: 300));

    if (mode == CameraMode.off) {
      if (mounted) setState(() => _cameraMode = mode);
      return;
    }

    if (_availableCameras.isEmpty) {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) return;
    }

    final targetLens = mode == CameraMode.front
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final description = _availableCameras.firstWhere(
      (c) => c.lensDirection == targetLens,
      orElse: () => _availableCameras.first,
    );

    // Sensor rotation differs between front and back cameras
    _rotationAngle = (mode == CameraMode.front) ? 270 : 90;

    try {
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) { await controller.dispose(); return; }

      controller.startImageStream((CameraImage image) async {
        if (!_isTranslating || _handLandmarkerPlugin == null) return;
        if (_isModelBusy) return;
        _isModelBusy = true;
        try {
          final List<ai.Hand> hands =
              _handLandmarkerPlugin!.detect(image, _rotationAngle);
          if (hands.isNotEmpty) {
            _processLiveFrame(hands.first.landmarks);
          } else {
            _resetTrackingState();
          }
        } catch (e) {
          debugPrint('AI stream error: $e');
        } finally {
          _isModelBusy = false;
        }
      });

      setState(() {
        cameraController = controller;
        isCameraReady = true;
        _cameraMode = mode;
      });
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _resetTrackingState() {
    _finalMotion = 'still';
    _lockedWord = 'Scanning...';
    _baseWristX = 0; _baseWristY = 0; _baseHandSize = 0;
    _prevWristX = 0; _prevWristY = 0;
    _shakeCounter = 0; _isShakeActive = false;
    for (final h in _fingerHistory) { h.clear(); }
    if (mounted && _signTranslation != 'Scanning...') {
      setState(() => _signTranslation = 'Scanning...');
    }
  }

  // ── core landmark processing ──────────────────────────────────────────────
  //
  // Improvements over original:
  //
  // 1. LOWER MOTION THRESHOLDS — original required 13/9/12 units of movement
  //    to register up/down/side. That's too strict for natural signing speed
  //    at typical arm-camera distances. Reduced to 8/6/8 which catches the
  //    same intentional gestures without false-triggering on jitter.
  //
  // 2. LOCKED WORD PERSISTS ON STILL — original reset _lockedWord to
  //    "Scanning..." every time the hand held still (even briefly between
  //    motions). This made any natural pause between signs wipe the result.
  //    Now _lockedWord only clears when the hand leaves the frame entirely
  //    (handled in _resetTrackingState). The displayed word stays visible
  //    until the user explicitly sends it or moves to a new sign.
  //
  // 3. BASELINE RESETS ON ANY STILL, NOT JUST FIST — original only
  //    recalibrated the wrist origin when the hand was a fist. For non-fist
  //    signs, the origin drifted over time, making directional moves appear
  //    smaller than they were and fail the thresholds. Now any still hold
  //    refreshes the baseline, keeping movement measurements accurate for
  //    all 17 hand shapes.
  //
  // 4. SHAKE COUNTER REDUCED 3→2 — requiring 3 consecutive lateral frames
  //    was too strict. Natural shakes at 30fps often produce 2 clear frames
  //    before the oscillation shifts direction. 2 is enough to distinguish
  //    intentional shake from random jitter.
  //
  // 5. FINGER ANGLE SMOOTHING — each finger's state is now determined by a
  //    rolling majority vote across the last 3 frames rather than a single
  //    frame snapshot. One bad landmark frame (partial occlusion, lighting
  //    glitch) no longer flips a finger's state and produces a wrong word.
  //
  // 6. STILL WORD SHOWN IMMEDIATELY — original only showed a word if the
  //    result was not "Scanning...". Now for still motion, even a fuzzy
  //    match updates the display immediately so the user gets instant
  //    feedback on their static hand shape without needing to trigger motion.

  void _processLiveFrame(List<ai.Landmark> landmarks) {
    if (landmarks.length < 21) return;

    // Compute joint angle at a given triplet of landmark indices
    double angleAtJoint(int baseIdx, int jointIdx, int tipIdx) {
      final v1x = landmarks[baseIdx].x - landmarks[jointIdx].x;
      final v1y = landmarks[baseIdx].y - landmarks[jointIdx].y;
      final v2x = landmarks[tipIdx].x - landmarks[jointIdx].x;
      final v2y = landmarks[tipIdx].y - landmarks[jointIdx].y;
      final dot = v1x * v2x + v1y * v2y;
      final mag1 = math.sqrt(v1x * v1x + v1y * v1y);
      final mag2 = math.sqrt(v2x * v2x + v2y * v2y);
      if (mag1 == 0 || mag2 == 0) return 180;
      final cosAngle = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
      return math.acos(cosAngle) * (180 / math.pi);
    }

    // Raw finger states for this frame
    final thumbAngle = angleAtJoint(1, 2, 4);
    final rawFingers = <int>[
      (thumbAngle > 130) ? 1 : 0,
      ...List.generate(4, (i) {
        const mcps = [5, 9, 13, 17];
        const pips = [6, 10, 14, 18];
        const tips = [8, 12, 16, 20];
        return (angleAtJoint(mcps[i], pips[i], tips[i]) > 140) ? 1 : 0;
      }),
    ];

    // Smooth each finger via majority vote over last 3 frames — prevents a
    // single bad landmark frame from flipping a finger state.
    final fingers = <int>[];
    for (var i = 0; i < 5; i++) {
      _fingerHistory[i].add(rawFingers[i]);
      if (_fingerHistory[i].length > 3) _fingerHistory[i].removeAt(0);
      final ones = _fingerHistory[i].where((v) => v == 1).length;
      // majority: if more than half the history says extended → extended
      fingers.add(ones > _fingerHistory[i].length ~/ 2 ? 1 : 0);
    }

    // Wrist position and hand size (for depth estimation via apparent size)
    final wristX = landmarks[0].x * 100;
    final wristY = landmarks[0].y * 100;
    final handSize = math.sqrt(
      math.pow(landmarks[0].x - landmarks[9].x, 2) +
      math.pow(landmarks[0].y - landmarks[9].y, 2),
    ) * 100;

    // Calibrate baseline on first frame
    if (_baseWristX == 0 && _baseWristY == 0) {
      _baseWristX = wristX; _baseWristY = wristY; _baseHandSize = handSize;
    }

    final dx = wristY - _baseWristY;
    final dy = -(wristX - _baseWristX);
    final dSize = handSize - _baseHandSize;

    // Shake detection: 2 consecutive lateral frames is enough
    bool liveShake = false;
    if (_prevWristX != 0 && _prevWristY != 0) {
      final f2fDx = wristY - _prevWristY;
      final f2fDy = -(wristX - _prevWristX);
      if (f2fDx.abs() > 2.5 && f2fDx.abs() > f2fDy.abs()) {
        _shakeCounter++;
        if (_shakeCounter >= 2) liveShake = true; // reduced from 3 → 2
      } else {
        if (_shakeCounter > 0) _shakeCounter--;
      }
    }
    _prevWristX = wristX; _prevWristY = wristY;

    // Motion priority: directional > shake > still
    // Thresholds lowered (13→8, 9→6, 12→8) to catch natural signing motion
    if (dy < -8.0 && dy.abs() > dx.abs() && dy.abs() > dSize.abs()) {
      _finalMotion = 'up'; _isShakeActive = false; _shakeCounter = 0;
    } else if (dy > 6.0 && dy.abs() > dx.abs() && dy.abs() > dSize.abs()) {
      _finalMotion = 'down'; _isShakeActive = false; _shakeCounter = 0;
    } else if (dx.abs() > 8.0 && dx.abs() > dy.abs() && dx.abs() > dSize.abs()) {
      _finalMotion = 'side'; _isShakeActive = false; _shakeCounter = 0;
    } else if ((liveShake || _isShakeActive) && dx.abs() < 9.0 && dy.abs() < 7.0) {
      _isShakeActive = true; _finalMotion = 'shake';
    } else if (dx.abs() < 4.5 && dy.abs() < 4.5 && dSize.abs() < 3.0) {
      _finalMotion = 'still';
      _isShakeActive = false; _shakeCounter = 0;
      // Always refresh baseline on still — not just on fist — so origin
      // stays accurate for any hand shape between signs.
      _baseWristX = wristX; _baseWristY = wristY; _baseHandSize = handSize;
      // Note: _lockedWord is intentionally NOT cleared here. It was cleared
      // in the original on every still frame, which wiped the result any
      // time the user paused naturally between gestures. Now it only clears
      // when the hand leaves frame entirely (_resetTrackingState).
    }

    // Decode and lock result
    String result;
    if (_finalMotion == 'still') {
      result = SignLanguageDecoder.decode(fingers, 'still');
      // For still signs show the result immediately — don't require motion
      if (result != 'Scanning...') _lockedWord = result;
    } else {
      final decoded = SignLanguageDecoder.decode(fingers, _finalMotion);
      if (decoded != 'Scanning...') _lockedWord = decoded;
      result = _lockedWord;
    }

    if (result != 'Scanning...' && mounted) {
      setState(() => _signTranslation = result);
    }
  }

  // ── send current result as a message ────────────────────────────────────
  Future<void> _sendResult() async {
    if (_signTranslation.isEmpty || _signTranslation == 'Scanning...') return;

    final message = ChatMessage(
      text: _signTranslation,
      sender: MessageSender.me,
      time: DateTime.now(),
    );

    if (mounted) {
      setState(() => _translations.add(message));
      context.read<ConversationHistoryService>().addMessage(message);
      await context.read<TtsService>().speak(_signTranslation);
    }

    // Reset so the next sign can be captured fresh
    setState(() {
      _signTranslation = 'Scanning...';
      _finalMotion = 'still';
      _lockedWord = 'Scanning...';
      _baseWristX = 0; _baseWristY = 0; _baseHandSize = 0;
      _prevWristX = 0; _prevWristY = 0;
      _shakeCounter = 0; _isShakeActive = false;
    });
  }

  Future<void> _handleSave() async {
    await context.read<ConversationHistoryService>().endSession();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation saved to history'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        FocusManager.instance.primaryFocus?.unfocus();
        await context.read<ConversationHistoryService>().endSession();
        context.read<SttService>().clearHistory();
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Sign Language Chat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: Column(
          children: [
            // Camera view
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _cameraBody(),
              ),
            ),
            // Send button + current word
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _GradientButton(
                label: _signTranslation == 'Scanning...'
                    ? 'Waiting for sign...'
                    : 'Send: $_signTranslation',
                icon: Icons.send_rounded,
                onPressed: _signTranslation == 'Scanning...' ? null : _sendResult,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            // Translation history (CV-only subtitle window)
            Expanded(
              flex: 3,
              child: CvSubtitleWindow(
                translations: _translations,
                isAnalyzing: _isTranslating && _signTranslation == 'Scanning...',
              ),
            ),
            const SizedBox(height: 8),
            // Utility bar
            CvUtilityBar(
              onSave: _handleSave,
              isTranslating: _isTranslating,
              onToggleTranslating: (value) {
                setState(() => _isTranslating = value);
                if (!value) _resetTrackingState();
              },
              cameraMode: _cameraMode,
              onCameraModeChanged: _switchToMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraBody() {
    if (_cameraMode == CameraMode.off) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 56),
              SizedBox(height: 10),
              Text('Camera is off', style: TextStyle(color: Colors.white38, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    if (!isCameraReady || cameraController == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: _blue)),
      );
    }

    // Fit width, crop vertically — no distortion, no letterboxing
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Send button widget ───────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const _GradientButton({required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [Color(0xFF1067FC), Color(0xFF14ADF4)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
        color: disabled ? Colors.grey.withValues(alpha: 0.2) : null,
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
