import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_silent_voice/components/live_subtitle_window.dart';
import 'package:the_silent_voice/components/response_suggestion.dart';
import 'package:the_silent_voice/components/utility_navigation_bar.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/services/stt_service.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ConversationHistoryService>().startSession();
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
        if (context.mounted) {
          Navigator.of(context).pop();
        }
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
            const LiveSubtitleWindow(),
            Expanded(flex: 2, child: ResponseSuggestion()),
            UtilityNavigationBar(),
          ],
        ),
      ),
    );
  }
}