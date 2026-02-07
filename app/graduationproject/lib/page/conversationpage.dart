import 'package:flutter/material.dart';

class Conversationpage extends StatelessWidget {
  const Conversationpage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme colors and text styles from context
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Conversation',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 3,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: colorScheme.outlineVariant, height: 1.5),
        ),
      ),
      body: Container(), // Add your conversation UI here
    );
  }
}
