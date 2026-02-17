import 'package:flutter/material.dart';

/// ### Component 1: Live Subtitle Display
///
/// - a rounded box that take the upper third or the screan
/// - it display the text in real time
/// - it take text from a speach-to-text model
/// - when text reach the end of the box it bush the old text to the top
/// - you can swipe to see the older text from the start of that conversation
///
class LiveSubtitleWindow extends StatefulWidget {
  const LiveSubtitleWindow({super.key});

  @override
  State<LiveSubtitleWindow> createState() => _LiveSubtitleWindowState();
}

class _LiveSubtitleWindowState extends State<LiveSubtitleWindow> {
  final ScrollController _scrollController = ScrollController();

  // list of the converted text
  // well pipe the text to it (ngl idk how)
  // Sample conversation text - replace with actual speech-to-text data
  final List<String> conversationLines = [
    //'text line 1',
    //'text line 2',
    //'text line 3',
    //'text line 4',
    //'text line 5',
    //'text line 6',
    //'text line 7',
    //'text line 8',
    //'text line 9',
    //'long text line ............................................................................................................',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + 1;
    final availableHeight = screenHeight - appBarHeight;
    final subtitleHeight = availableHeight / 3;

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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.mic,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Live Subtitle',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 2),

          /// #### Text container
          /// - it show text if existing
          /// - else it show 'Listening...'
          // ###### Missing behavier need to be done:
          // - the text does not update to keep new text at the bottom of the screan
          Expanded(
            child: conversationLines.isEmpty
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Listening...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: conversationLines.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          conversationLines[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
