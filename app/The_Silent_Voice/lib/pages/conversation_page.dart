import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/chat_list.dart';
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
class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  /// controller for chat scrolling
  final ScrollController scroll = ScrollController();
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
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
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
            Expanded(flex: 2, child: ResponseSuggestion()),
            /// Component 3: Chat History
            /// Reverse ListView:
            /// - newest messages appear at the bottom
            /// - scroll grows upward
            Expanded(
              flex: 3,
              child: ListView.builder(
                controller: scroll,
                /// reverse list for chat UX
                reverse: true,
                /// optimize layout size
                shrinkWrap: true,
                /// prevents overscroll glow 
                physics: const ClampingScrollPhysics(),
                itemCount: chat.length,
                itemBuilder: (_, idex){
                  /// reverse index to match reversed list
                  final reverseIdex = chat.length-1-idex;
                  /// chat bubble UI
                  return BubbleSpecialThree(
                    text: chat[reverseIdex],
                    color: Color(0xFF1B97F3),
                    tail: false,
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                  );
                },
              ),
            ),

            /// Component 4: Utility Bar
            /// Handles:
            /// - gesture-based responses (Yes / No / etc.)
            /// - manual message input
            /// - saving conversations
            /// Data Flow:
            /// UtilityNavigationBar → callback → update chat list
            UtilityNavigationBar(
              onMessageSent: (text) {
                /// append new message to chat history
                setState(() {
                  chat.add(text); 
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
