import 'package:flutter/material.dart';

/// # Privacy & Security Page
///
/// Displays the app's privacy policy and security practices.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const SizedBox(height: 10),
          SectionCard(
            icon: Icons.lock_outline_rounded,
            title: 'Data Storage',
            body:
                'Your conversations and profile data are stored securely in '
                'Firebase with industry-standard encryption. Only you can '
                'access your personal data.',
          ),
          SectionCard(
            icon: Icons.share_outlined,
            title: 'Data Sharing',
            body:
                'We do not sell or share your personal data with third parties. '
                'Your data is used solely to provide the app\'s features and '
                'improve your experience.',
          ),
          SectionCard(
            icon: Icons.photo_outlined,
            title: 'Profile Images',
            body:
                'Profile photos you upload are stored on Cloudinary under your '
                'account. They are not publicly accessible without your direct '
                'link.',
          ),
          SectionCard(
            icon: Icons.account_circle_outlined,
            title: 'Account Security',
            body:
                'Authentication is handled by Firebase Auth. We recommend '
                'using a strong, unique password to keep your account safe. '
                'You can also reset your password if you forget it.',
          ),
          SectionCard(
            icon: Icons.history_rounded,
            title: 'Conversation History',
            body:
                'Your conversation sessions are stored privately in Firestore '
                'and are only visible to you when you are logged in.',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Reusable card widget for each privacy section
class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const SectionCard({super.key, 
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.secondary,
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}