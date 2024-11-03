import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/providers/feedback_provider.dart';
import 'package:the_bridge_app/widgets/common_app_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedType = 'suggestion';
  bool _isSubmitting = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<FeedbackProvider>().submitFeedback(
            type: _selectedType,
            content: _feedbackController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit feedback. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Send Feedback'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _animationController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  'Help us improve',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your feedback helps us make The Bridge App better for everyone.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Feedback Type Selection
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Suggestion'),
                        subtitle: const Text('Share your ideas for improvement'),
                        value: 'suggestion',
                        groupValue: _selectedType,
                        onChanged: (value) => setState(() => _selectedType = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Bug Report'),
                        subtitle: const Text('Help us fix technical issues'),
                        value: 'bug',
                        groupValue: _selectedType,
                        onChanged: (value) => setState(() => _selectedType = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Content'),
                        subtitle: const Text('Report issues with app content'),
                        value: 'content',
                        groupValue: _selectedType,
                        onChanged: (value) => setState(() => _selectedType = value!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bug Report Tips Section
                if (_selectedType == 'bug') ...[
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips for bug reports:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Describe what happened\n'
                            '• Include steps to reproduce\n'
                            '• What did you expect to happen?\n'
                            '• What actually happened?',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Feedback Input Section
                const SizedBox(height: 16),
                Text(
                  'Your feedback',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _feedbackController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: _selectedType == 'bug' ? 'Please describe the issue in detail. Include steps to reproduce if possible.' : 'Write your feedback here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                // Submit Button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSubmitting ? 'Sending...' : 'Send Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
