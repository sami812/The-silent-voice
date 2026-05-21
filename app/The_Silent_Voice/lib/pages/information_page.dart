import 'package:flutter/material.dart';

/// # App Information Page
///
/// Displays details about The Silent Voice app:
/// version, platform, tech stack, and a short description.
class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          /// App icon
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: const AssetImage('assets/icons/app_icon.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  'The Silent Voice',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// About description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: textTheme.titleSmall),
                  const Divider(),
                  Text(
                    'The Silent Voice is a communication and accessibility app designed to help users connect easily through both text and sign-based conversations. '
                    'The app provides a simple, modern, and user-friendly interface that supports smooth real-time communication.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Technical details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: textTheme.titleSmall),
                  const Divider(),
                  InfoRow(label: 'App Name', value: 'The Silent Voice'),
                  InfoRow(label: 'Version', value: '1.0.0'),
                  InfoRow(label: 'Platform', value: 'Android'),
                  InfoRow(label: 'Framework', value: 'Flutter'),
                  InfoRow(label: 'Language', value: 'English'),
                  InfoRow(label: 'Backend', value: 'Firebase'),
                  InfoRow(label: 'Media Storage', value: 'Cloudinary'),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

/// Reusable label/value row
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}