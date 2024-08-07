import 'package:flutter/foundation.dart';
import '../services/feedback_service.dart';
import 'package:the_bridge_app/models/feedback.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isSending = false;

  bool get isSending => _isSending;

  Future<void> sendFeedback(Feedback feedback) async {
    _isSending = true;
    notifyListeners();
    try {
      await _feedbackService.sendFeedback(feedback);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send feedback: $e');
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
