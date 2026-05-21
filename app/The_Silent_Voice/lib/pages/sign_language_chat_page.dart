import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool isCameraReady = false;
  bool isCameraOn = true;
  bool isAnalyzing = false;
  String signTranslation = '';
  static const Color blue = Color(0xFF1067FC);

  @override
  void initState() {
    super.initState();
    initCamera();
    context.read<ConversationHistoryService>().startSession();
  }

  @override
  void dispose() {
    cameraController?.dispose();
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
        imageFormatGroup: ImageFormatGroup.jpeg,
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
      debugPrint('Frame captured: ${frame.path}');
      await Future.delayed(const Duration(seconds: 2)); 
      const result = 'Hello, how are you?';
      setState(() {
        isAnalyzing = false;
        signTranslation = result;
      });
      if (mounted) {
        final msg = ChatMessage(
          text: result,
          sender: MessageSender.me,
          time: DateTime.now(),
        );
        context.read<ConversationHistoryService>().addMessage(msg);
      }
      if (mounted) await context.read<TtsService>().speak(result);
    } on CameraException catch (e) {
      setState(() => isAnalyzing = false);
      showError('Could not capture: ${e.description ?? e.code}');
    } catch (e) {
      setState(() => isAnalyzing = false);
      debugPrint('Capture error: $e');
    }
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
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
            Expanded(
              flex: 3,
              child: const LiveSubtitleWindow(),
            ),
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

  const _CameraToggleButton({
    required this.isCameraOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCameraOn
              ? Colors.black54
              : Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCameraOn
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
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
                colors: [
                  Color.fromARGB(255, 16, 103, 252),
                  Color.fromARGB(255, 20, 173, 244),
                ],
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
    final theme = Theme.of(context);
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
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          // if (trailing != null) trailing!,
        ],
      ),
    );
  }
}