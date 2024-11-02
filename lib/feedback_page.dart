import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/providers/feedback_provider.dart';
import 'package:the_bridge_app/widgets/common_app_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedType = 'suggestion';
  bool _isSubmitting = false;

  @override
  void dispose() {
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const Text(
                'Help us improve',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 24),

              // Feedback Type Selection
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
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
              const SizedBox(height: 24),

              // Feedback Input
              TextField(
                controller: _feedbackController,
                maxLines: 6,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: _selectedType == 'bug' ? 'Please describe the issue in detail. Include steps to reproduce if possible.' : 'Write your feedback here...',
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
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

              // Additional Info
              if (_selectedType == 'bug') ...[
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tips for bug reports',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('• Describe what happened'),
                        Text('• List the steps to reproduce'),
                        Text('• Include any error messages'),
                        Text('• Mention your device type'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
