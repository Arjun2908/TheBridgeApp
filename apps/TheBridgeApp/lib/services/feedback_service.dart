import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedbackService {
  final String sendGridApiKey = dotenv.env['SENDGRID_API_KEY']!;
  final String fromEmail = dotenv.env['FROM_EMAIL']!;
  final String toEmail = dotenv.env['TO_EMAIL']!;

  Future<void> sendFeedback(Map<String, dynamic> feedback) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final emailBody = '''
Type: ${feedback['type']}
Content: ${feedback['content']}
Timestamp: ${feedback['timestamp']}
Platform: ${feedback['platform']}
''';

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
            'subject': 'App Feedback - ${feedback['type'].toString().toUpperCase()}',
          }
        ],
        'from': {'email': fromEmail},
        'content': [
          {'type': 'text/plain', 'value': emailBody}
        ]
      }),
    );

    if (response.statusCode != 202) {
      throw Exception('Failed to send feedback');
    }
  }
}
