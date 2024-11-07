import 'package:flutter/foundation.dart';
import '../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isSending = false;

  bool get isSending => _isSending;

  Future<void> submitFeedback({
    required String type,
    required String content,
  }) async {
    _isSending = true;
    notifyListeners();

    try {
      final feedback = {
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.toString(),
      };

      await _feedbackService.sendFeedback(feedback);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send feedback: $e');
      }
      rethrow; // Rethrow to handle in UI
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
