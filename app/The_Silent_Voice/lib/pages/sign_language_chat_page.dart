import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:the_silent_voice/components/chat_message.dart';
import 'package:the_silent_voice/components/live_subtitle_window.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/services/stt_service.dart';
import 'package:the_silent_voice/services/tts_service.dart';

class VideoChatPage extends StatefulWidget {
  const VideoChatPage({super.key});

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  CameraController? cameraController;
  Interpreter? interpreter;
  List<String> labels = [];
  bool isCameraReady = false;
  bool isCameraOn = true;
  bool isAnalyzing = false;
  String signTranslation = '';
  static const Color blue = Color(0xFF1067FC);

  @override
  void initState() {
    super.initState();
    initProject();
    context.read<ConversationHistoryService>().startSession();
  }

  Future<void> initProject() async {
    await _loadModel();
    await initCamera();
  }

  Future<void> _loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/model/model.tflite');

      final raw = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/model/labels.txt');
      labels = raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint("Failed to load model: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    interpreter?.close();
    super.dispose();
  }

  Future<void> initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      await cameraController!.setFlashMode(FlashMode.off);
      if (mounted) setState(() => isCameraReady = true);
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} — ${e.description}');
      if (mounted) showError('Camera error: ${e.description ?? e.code}');
    } catch (e) {
      debugPrint('Unexpected camera error: $e');
    }
  }

  Future<void> toggleCamera() async {
    if (!isCameraReady) return;
    if (isCameraOn) {
      await cameraController?.pausePreview();
    } else {
      await cameraController?.resumePreview();
    }
    setState(() => isCameraOn = !isCameraOn);
  }

  Future<void> captureAndTranslate() async {
    if (!isCameraReady || !isCameraOn || isAnalyzing) return;

    setState(() => isAnalyzing = true);

    try {
      final XFile frame = await cameraController!.takePicture();

      final bytes = await File(frame.path).readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);

      if (decoded == null) throw Exception("decode failed");

      const int featureSize = 136;

      final img.Image resized = img.copyResize(decoded, width: 8, height: 17);

      List<double> input = [];

      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final p = resized.getPixel(x, y);

          double gray = (p.r + p.g + p.b) / 3.0;

          input.add((gray - 127.5) / 127.5);
        }
      }

      if (input.length != featureSize) {
        input = List<double>.filled(featureSize, 0.0);
      }

      final inputTensor = [input];

      final outputShape = interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List.filled(outputShape[1], 0.0),
      );

      interpreter!.run(inputTensor, output);
      debugPrint("RAW OUTPUT: $output");
      debugPrint("SCORES: ${output[0]}");

      final List<double> scores = List<double>.from(output[0]);

      int bestIndex = 0;
      double bestScore = scores[0];

      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > bestScore) {
          bestScore = scores[i];
          bestIndex = i;
        }
      }

      final result = (bestIndex < labels.length)
          ? labels[bestIndex]
          : "Unknown";
      debugPrint("PREDICTED LABEL: ${labels[bestIndex]}");
      setState(() {
        signTranslation = result;
        isAnalyzing = false;
      });

      if (mounted) {
        context.read<ConversationHistoryService>().addMessage(
          ChatMessage(
            text: result,
            sender: MessageSender.me,
            time: DateTime.now(),
          ),
        );

        await context.read<TtsService>().speak(result);
      }
    } catch (e) {
      debugPrint("Inference error: $e");
      setState(() => isAnalyzing = false);
    }
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
            'Conversation',
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
            Expanded(
              flex: 4,
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cameraBody(),
                    if (isAnalyzing)
                      const ColoredBox(
                        color: Color(0x881067FC),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                'Analyzing sign…',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _CameraToggleButton(
                        isCameraOn: isCameraOn,
                        onTap: toggleCamera,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _GradientButton(
                label: isAnalyzing ? 'Analyzing…' : 'Translate Sign',
                icon: isAnalyzing
                    ? Icons.hourglass_top_rounded
                    : Icons.sign_language_rounded,
                onPressed: (isAnalyzing || !isCameraReady || !isCameraOn)
                    ? null
                    : captureAndTranslate,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: signTranslation.isEmpty
                  ? const SizedBox(height: 8)
                  : _ResultTile(
                      text: signTranslation,
                      accentColor: blue,
                      trailing: Consumer<TtsService>(
                        builder: (_, tts, _) => IconButton(
                          icon: Icon(
                            tts.isSpeaking
                                ? Icons.stop_circle_rounded
                                : Icons.volume_up_rounded,
                            size: 22,
                          ),
                          color: blue,
                          onPressed: tts.isSpeaking
                              ? () => tts.stop()
                              : () => tts.speak(signTranslation),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(flex: 3, child: const LiveSubtitleWindow()),
          ],
        ),
      ),
    );
  }

  Widget cameraBody() {
    if (!isCameraReady) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: blue)),
      );
    }
    if (!isCameraOn) {
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
    return CameraPreview(cameraController!);
  }
}

class _CameraToggleButton extends StatelessWidget {
  final bool isCameraOn;
  final VoidCallback onTap;
  const _CameraToggleButton({required this.isCameraOn, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCameraOn ? Colors.black54 : Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              isCameraOn ? 'Camera On' : 'Camera Off',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const _GradientButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });
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
          padding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
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

class _ResultTile extends StatelessWidget {
  final String text;
  final Color accentColor;
  final Widget? trailing;
  const _ResultTile({
    required this.text,
    required this.accentColor,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          // if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
