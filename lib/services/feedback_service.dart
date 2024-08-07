import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:the_bridge_app/models/feedback.dart';

class FeedbackService {
  final String sendGridApiKey = dotenv.env['SENDGRID_API_KEY']!;
  final String fromEmail = dotenv.env['FROM_EMAIL']!;
  final String toEmail = dotenv.env['TO_EMAIL']!;

  Future<void> sendFeedback(Feedback feedback) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $sendGridApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'personalizations': [
          {
            'to': [
              {'email': toEmail}
            ],
            'subject': 'App Feedback - ${(feedback.name ?? 'Anonymous')}',
          }
        ],
        'from': {'email': fromEmail},
        'content': [
          {'type': 'text/plain', 'value': feedback.feedback}
        ]
      }),
    );

    if (response.statusCode != 202) {
      throw Exception('Failed to send feedback');
    }
  }
}
