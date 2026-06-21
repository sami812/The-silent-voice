import 'package:flutter/material.dart';
import 'package:the_silent_voice/components/chat_message.dart';

/// ### CV Subtitle Window
///
/// Like LiveSubtitleWindow, but only shows text produced by the computer
/// vision sign-language translator - never STT/speech input. Used on the
/// sign-language chat page as a running log of what the camera has
/// translated so far.
class CvSubtitleWindow extends StatefulWidget {
  final List<ChatMessage> translations;
  final bool isAnalyzing;

  const CvSubtitleWindow({
    super.key,
    required this.translations,
    required this.isAnalyzing,
  });

  @override
  State<CvSubtitleWindow> createState() => _CvSubtitleWindowState();
}

class _CvSubtitleWindowState extends State<CvSubtitleWindow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant CvSubtitleWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.translations.length != oldWidget.translations.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1, thickness: 2),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.sign_language_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text('Sign Translation', style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          if (widget.isAnalyzing) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Analyzing',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.translations.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Translated signs will appear here...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.translations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            widget.translations[index].text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}
