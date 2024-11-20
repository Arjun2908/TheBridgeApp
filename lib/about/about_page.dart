import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:the_bridge_app/providers/settings_provider.dart';

import 'package:the_bridge_app/about/helpers.dart';
import 'package:the_bridge_app/feedback_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('About'),
            forceMaterialTransparency: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.church_outlined, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'The Bridge App',
                        style: TextStyle(
                          fontSize: getHeaderTextSize(settingsProvider.textSize),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Equipping Christians to Share the Gospel',
                        style: TextStyle(
                          fontSize: getBodyTextSize(settingsProvider.textSize),
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // About Section
                      _buildSection(
                        context: context,
                        settingsProvider: settingsProvider,
                        icon: Icons.info_outline,
                        title: 'About',
                        content:
                            'The Bridge App is designed to help Christians share the gospel with others, and equip them to do the same. It provides a visual tool to help explain the gospel message in a clear and engaging way.',
                      ),

                      // Features Section
                      _buildSection(
                        context: context,
                        settingsProvider: settingsProvider,
                        icon: Icons.star_outline,
                        title: 'Features',
                        content: null,
                        child: Column(
                          children: [
                            _buildFeatureItem(context, 'AI Practice Mode', 'Multiple personality types for realistic conversations'),
                            _buildFeatureItem(context, 'Question Bank', 'Searchable answers with tag filtering'),
                            _buildFeatureItem(context, 'Interactive Tools', 'Note-taking and drawing canvas'),
                            _buildFeatureItem(context, 'Resource Library', 'Comprehensive learning materials'),
                            _buildFeatureItem(context, 'Customization', 'Dark mode and text size options'),
                            _buildFeatureItem(context, 'Sharing', 'Export and share your notes'),
                          ],
                        ),
                      ),

                      // Team Section
                      _buildSection(
                        context: context,
                        settingsProvider: settingsProvider,
                        icon: Icons.people_outline,
                        title: 'Our Team',
                        content: 'Our team is passionate about sharing the gospel of Jesus and equipping others to do the same.',
                        child: Column(
                          children: [
                            _buildTeamMember(context, 'Arjun Gupta', 'Developer'),
                            _buildTeamMember(context, 'Bradley Hicks', 'Script and Content Creator'),
                            _buildTeamMember(context, 'Rachel Hicks', 'Graphics Designer'),
                          ],
                        ),
                      ),

                      // Contact Section
                      _buildSection(
                        context: context,
                        settingsProvider: settingsProvider,
                        icon: Icons.mail_outline,
                        title: 'Contact Us',
                        content: null,
                        child: Column(
                          children: [
                            Text(
                              "We're eager to hear your feedback and suggestions to make this app even better.",
                              style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize)),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.email_outlined),
                              label: const Text('support@arjungupta.dev'),
                              onPressed: () {/* Add email launch functionality */},
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.feedback_outlined),
                              label: const Text('Send Feedback'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required SettingsProvider settingsProvider,
    required IconData icon,
    required String title,
    String? content,
    Widget? child,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: getTitleTextSize(settingsProvider.textSize),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (content != null) ...[
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize)),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 16),
              child,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, String name, String role) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          name[0],
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      title: Text(name),
      subtitle: Text(role),
    );
  }
}
