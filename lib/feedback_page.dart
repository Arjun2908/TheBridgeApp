import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/models/feedback.dart' as feedback;
import '../providers/feedback_provider.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback and Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name (Optional)'),
                autofocus: true,
              ),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(labelText: 'Your Feedback'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Consumer<FeedbackProvider>(
                builder: (context, feedbackProvider, child) {
                  return feedbackProvider.isSending
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              feedbackProvider.sendFeedback(feedback.Feedback(feedback: _feedbackController.text, name: _nameController.text == '' ? null : _nameController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Feedback submitted successfully')),
                              );
                              _feedbackController.clear();
                            }
                          },
                          child: const Text('Submit Feedback'),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
