import 'package:flutter/material.dart';
import 'package:the_silent_voice/components/live_subtitle_window.dart';
import 'package:the_silent_voice/components/responce_sugestion.dart';
import 'package:the_silent_voice/components/utility_navigation_bar.dart';

class Conversationpage extends StatelessWidget {
  const Conversationpage({super.key});

  /// # the Converstaition page
  ///
  /// - responsable for creatign and mentaining conversation
  /// - the main funciton of the app
  /// - contain 3 main component
  ///       1. Live Subtitle Display (scrollable conversation)
  ///       2. list of responce suggesiton (based on context)
  ///       3. utility bar (collection of important tool)
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversation',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Column(
        children: [
          // 1. Live Subtitle Display
          LiveSubtitleWindow(),
          // 2. list of responce suggesiton
          Expanded(child: ResponseSuggestion()),
          // 3. utility bar
          UtilityNavigationBar(),
        ],
      ),
    );
  }
}
