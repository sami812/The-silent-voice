import 'package:flutter/material.dart';

/// # Language Page
///
/// Displays the available app languages.
/// Currently only English is supported.
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'App Language',
              style: textTheme.titleSmall,
            ),
          ),
          const Divider(),

          /// English – active & only option
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              radius: 18,
              child: Text(
                'EN',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text('English', style: textTheme.displaySmall),
            subtitle: Text(
              'English (United States)',
              style: textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
            trailing: Icon(Icons.check_circle, color: colorScheme.secondary),
            onTap: () {}, // already selected
          ),

          const Divider(),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'More languages will be available in future updates.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}