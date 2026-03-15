import 'package:flutter/material.dart';
import 'package:the_silent_voice/components/live_subtitle_window.dart';
import 'package:the_silent_voice/components/responce_sugestion.dart';
import 'package:the_silent_voice/components/utility_navigation_bar.dart';
/// Main screen responsible for managing the conversation flow.
///
/// Composition:
/// 1. LiveSubtitleWindow   → Displays real-time subtitles.
/// 2. ResponseSuggestion   → Context based suggested responses.
/// 3. UtilityNavigationBar → Gesture tools + custom input.
///
/// This page represents the primary interaction screen of the app.
class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      /// Prevent default back navigation behavior
      canPop: false,
      /// Custom back handling:
      /// - Close keyboard if open
      /// - Wait briefly for layout stabilization
      /// - Then manually pop the route
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        /// Prevent body resize when keyboard appears.
        /// UtilityNavigationBar handles keyboard offset manually.
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          /// Page title
          title: Text(
            'Conversation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
          /// Thin divider under the AppBar
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: Column(
          children: [
            /// Component 1:
            /// Displays live subtitles of the current conversation
            const LiveSubtitleWindow(),
            /// Component 2:
            /// Context-aware suggested responses
            const Expanded(
              child: ResponseSuggestion(),
            ),
            /// Component 3:
            /// Bottom utility bar with gesture controls
            const UtilityNavigationBar(),
          ],
        ),
      ),
    );
  }
}