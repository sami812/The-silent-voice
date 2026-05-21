import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/components/conversation_session.dart';
import 'package:the_silent_voice/components/chat_message.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<ConversationHistoryService>().loadSessions();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.blue),
            const SizedBox(width: 10),
            Text('History', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).colorScheme.outline,
            height: 1,
          ),
        ),
        actions: [
          // Refresh if needed
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<ConversationHistoryService>().refreshSessions();
            },
          ),
        ],
      ),
      body: Consumer<ConversationHistoryService>(
        builder: (context, historyService, child) {
          if (historyService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (historyService.sessions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyService.sessions.length,
            itemBuilder: (context, index) {
              final session = historyService.sessions[index];
              return _buildSessionCard(context, session);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation to see it here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, ConversationSession session) {
    final totalMessages = session.messages.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSessionDetails(context, session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (session.personName.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      session.personName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 92, 91, 91),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalMessages msgs',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color:Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalMessages msgs',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              Divider(),
              if (session.messages.isNotEmpty) ...[
                Text(
                  session.messages.first.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
              ],

              Row(
                children: [
                  _buildStat(context, Icons.mic, '${session.transcript.length} lines'),
                  const SizedBox(width: 16),
                  if (session.myMessages.isNotEmpty)
                    _buildStat(
                      context,
                      Icons.reply,
                      '${session.myMessages.length} replies',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grayColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    return Row(
      children: [
        Icon(icon, size: 14, color:grayColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: grayColor,
          ),
        ),
      ],
    );
  }

  void _editPersonName(BuildContext context, ConversationSession session) {
    final controller = TextEditingController(text: session.personName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Person\'s Name', style: Theme.of(context).textTheme.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter name...',
            prefixIcon: const Icon(Icons.person),
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              context.read<ConversationHistoryService>().updatePersonName(session.id, name);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: Text('Save', style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }

  void _copyConversation(BuildContext context, ConversationSession session) {
    final buffer = StringBuffer();
    buffer.writeln(
      session.personName.isNotEmpty
          ? 'Conversation with ${session.personName}'
          : 'Conversation',
    );
    buffer.writeln(DateFormat('dd MMM yyyy – hh:mm a').format(session.startTime));
    buffer.writeln('─' * 30);
    for (final msg in session.messages) {
      final sender = msg.sender == MessageSender.me ? 'Me' : (session.personName.isNotEmpty ? session.personName : 'Other');
      buffer.writeln('$sender: ${msg.text}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, ConversationSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.personName.isNotEmpty
                            ? session.personName
                            : DateFormat('dd MMM yyyy – hh:mm a').format(session.startTime),
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: 'Copy conversation',
                      onPressed: () => _copyConversation(context, session),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit name',
                      onPressed: () => _editPersonName(context, session),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('dd MMM yyyy – hh:mm a').format(session.startTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: session.messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages in this conversation',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: session.messages.length,
                        itemBuilder: (context, index) {
                          final msg = session.messages[index];
                          final isMe = msg.sender == MessageSender.me;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.lightBlue
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                msg.text,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isMe ? Theme.of(context).colorScheme.onPrimary : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}