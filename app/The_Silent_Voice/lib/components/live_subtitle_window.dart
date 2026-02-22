import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_silent_voice/services/stt_service.dart';

/// ### Component 1: Live Subtitle Display
///
/// - a rounded box that take the upper third of the screen
/// - it display the text in real time
/// - it take text from a speech-to-text model
/// - when text reach the end of the box it pushes the old text to the top
/// - you can swipe to see the older text from the start of that conversation
///
class LiveSubtitleWindow extends StatefulWidget {
  const LiveSubtitleWindow({super.key});

  @override
  State<LiveSubtitleWindow> createState() => _LiveSubtitleWindowState();
}

class _LiveSubtitleWindowState extends State<LiveSubtitleWindow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-start listening when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SttService>().startListening();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Auto-scroll to bottom when new text arrives
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + 1;
    final availableHeight = screenHeight - appBarHeight;
    final subtitleHeight = availableHeight / 3;

    return Consumer<SttService>(
      builder: (context, sttService, child) {
        // Auto-scroll to bottom whenever text updates
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Container(
          height: subtitleHeight,
          margin: EdgeInsets.all(16),
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
              // Header
              _buildHeader(context, sttService),
              Divider(height: 1, thickness: 2),

              // Text container
              Expanded(child: _buildTextContent(context, sttService)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SttService sttService) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.mic,
            size: 20,
            // Red when listening, normal color when not
            color: sttService.isListening
                ? Colors.red
                : Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: 8),
          Text('Live Subtitle', style: Theme.of(context).textTheme.titleSmall),
          Spacer(),
          // Live indicator when listening
          if (sttService.isListening) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Live',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 14, color: Colors.red),
            ),
          ],
          SizedBox(width: 8),
          // Play/Pause button
          GestureDetector(
            onTap: () => sttService.toggleListening(),
            child: Icon(
              sttService.isListening ? Icons.pause : Icons.play_arrow,
              size: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, SttService sttService) {
    // Check if there's any content
    final hasHistory = sttService.conversationHistory.isNotEmpty;
    final hasCurrentText = sttService.currentText.isNotEmpty;

    // If no content at all, show placeholder
    if (!hasHistory && !hasCurrentText) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            sttService.isListening
                ? 'Listening...'
                : 'Tap play to start listening',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Build the list of text lines
    // History = completed sentences
    // CurrentText = sentence being spoken right now (shown in italic)
    final allLines = [
      ...sttService.conversationHistory,
      if (hasCurrentText) sttService.currentText,
    ];

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: allLines.length,
      itemBuilder: (context, index) {
        // Check if this is the current (partial) text
        final isCurrentText = index == allLines.length - 1 && hasCurrentText;

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            allLines[index],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              // Current text is italic to show it's still being spoken
              fontStyle: isCurrentText ? FontStyle.italic : FontStyle.normal,
              // Current text has accent color
              color: isCurrentText
                  ? Theme.of(context).colorScheme.secondary
                  : null,
            ),
          ),
        );
      },
    );
  }
}
