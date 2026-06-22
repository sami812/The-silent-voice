import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_silent_voice/components/chat_message.dart';
import 'package:the_silent_voice/components/cv_subtitle_window.dart';
import 'package:the_silent_voice/components/cv_utility_bar.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/services/sign_language_service.dart';
import 'package:the_silent_voice/services/stt_service.dart';
import 'package:the_silent_voice/services/tts_service.dart';

class VideoChatPage extends StatefulWidget {
  const VideoChatPage({super.key});

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  CameraController? cameraController;
  List<CameraDescription> _availableCameras = [];
  CameraMode _cameraMode = CameraMode.front;
  bool isCameraReady = false;

  bool _isTranslating = false;
  bool isAnalyzing = false;
  Timer? _translateLoop;

  final List<ChatMessage> _translations = [];

  static const Color blue = Color(0xFF1067FC);
  static const int _burstFrameCount = 1;
  static const Duration _burstFrameDelay = Duration(milliseconds: 200);
  // how often the auto-translate loop attempts a capture while "Translating"
  // is on. Kept a bit longer than the burst+network round trip so captures
  // don't pile up on top of each other.
  static const Duration _autoTranslateInterval = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _setupCamera();
    context.read<ConversationHistoryService>().startSession();
    _translateLoop = Timer.periodic(_autoTranslateInterval, (_) {
      if (_isTranslating && _cameraMode != CameraMode.off && !isAnalyzing) {
        captureAndTranslate();
      }
    });
  }

  @override
  void dispose() {
    _translateLoop?.cancel();
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _setupCamera() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) return;
      await _switchToMode(_cameraMode);
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} — ${e.description}');
      if (mounted) showError('Camera error: ${e.description ?? e.code}');
    } catch (e) {
      debugPrint('Unexpected camera error: $e');
    }
  }

  /// Switches between front / back / off. Disposes the current controller
  /// (if any) and initializes a fresh one for the requested camera, since
  /// CameraController doesn't support swapping its target camera in place.
  Future<void> _switchToMode(CameraMode mode) async {
    final previousController = cameraController;
    if (mounted) {
      setState(() {
        isCameraReady = false;
        cameraController = null;
      });
    }
    await previousController?.dispose();
    // brief delay so the camera hardware is fully released before the next
    // controller tries to claim it - switching cameras back-to-back without
    // this can silently fail on some Android devices.
    await Future.delayed(const Duration(milliseconds: 300));

    if (mode == CameraMode.off) {
      if (mounted) setState(() => _cameraMode = mode);
      return;
    }

    if (_availableCameras.isEmpty) {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) return;
    }

    final targetLens =
        mode == CameraMode.front ? CameraLensDirection.front : CameraLensDirection.back;
    final description = _availableCameras.firstWhere(
      (c) => c.lensDirection == targetLens,
      orElse: () => _availableCameras.first,
    );

    try {
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        cameraController = controller;
        isCameraReady = true;
        _cameraMode = mode;
      });
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} — ${e.description}');
      if (mounted) showError('Camera error: ${e.description ?? e.code}');
    }
  }

  /// Captures a short burst of frames and sends them together so the
  /// sign-language service can interpret motion, not just one static pose.
  Future<void> captureAndTranslate() async {
    if (cameraController == null ||
        !isCameraReady ||
        _cameraMode == CameraMode.off ||
        isAnalyzing) {
      return;
    }

    setState(() => isAnalyzing = true);

    try {
      final List<File> frames = [];
      for (int i = 0; i < _burstFrameCount; i++) {
        final XFile shot = await cameraController!.takePicture();
        frames.add(File(shot.path));
        if (i < _burstFrameCount - 1) {
          await Future.delayed(_burstFrameDelay);
        }
      }

      final result = await SignLanguageService.translateSign(frames);

      if (!mounted) return;

      final isUsable = result != SignLanguageService.unclearResult &&
          result != 'Translation failed. Please try again.' &&
          !result.startsWith('Error:') &&
          result != 'No frames captured.';

      if (isUsable) {
        final message = ChatMessage(
          text: result,
          sender: MessageSender.me,
          time: DateTime.now(),
        );
        setState(() => _translations.add(message));
        context.read<ConversationHistoryService>().addMessage(message);
        await context.read<TtsService>().speak(result);
      }
    } catch (e) {
      debugPrint("Translation error: $e");
    } finally {
      if (mounted) setState(() => isAnalyzing = false);
    }
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
        // layout: camera view on top, subtitle window in the middle,
        // utility bar pinned to the bottom.
        body: Column(
          children: [
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
                child: cameraBody(),
              ),
            ),
            Expanded(
              flex: 3,
              child: CvSubtitleWindow(
                translations: _translations,
                isAnalyzing: isAnalyzing,
              ),
            ),
            const SizedBox(height: 12),
            CvUtilityBar(
              onSave: _handleSave,
              isTranslating: _isTranslating,
              onToggleTranslating: (value) => setState(() => _isTranslating = value),
              cameraMode: _cameraMode,
              onCameraModeChanged: _switchToMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget cameraBody() {
    if (_cameraMode == CameraMode.off) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 56),
              SizedBox(height: 10),
              Text(
                'Camera is off',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    if (!isCameraReady || cameraController == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: blue)),
      );
    }

    final camera = cameraController!;

    // "Zoom out to fit width, crop vertically" - the preview is scaled
    // down/up so its width always matches the available width exactly
    // (no horizontal cropping, no horizontal stretching), and whatever
    // sticks out vertically is cropped off the top/bottom rather than
    // trying to letterbox or squeeze the whole sensor frame in.
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
                height: constraints.maxWidth * camera.value.aspectRatio,
                child: CameraPreview(camera),
              ),
            ),
          ),
        );
      },
    );
  }
}
