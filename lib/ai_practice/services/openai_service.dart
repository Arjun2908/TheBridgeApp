import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:characters/characters.dart';

class OpenAIService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';
  final HtmlUnescape _unescape = HtmlUnescape();

  String _sanitizeResponse(String response) {
    // First, normalize Unicode characters
    response = response.characters.toList().join();

    // Replace various Unicode apostrophe variants with standard apostrophe
    final apostropheVariants = {
      'â€™': "'", // UTF-8 encoded right single quotation mark
      'â€˜': "'", // UTF-8 encoded left single quotation mark
      ''': "'",     // Unicode right single quotation mark (U+2019)
      ''': "'", // Unicode left single quotation mark (U+2018)
      '´': "'", // Acute accent
      '`': "'", // Grave accent
      'â': "'", // Corrupted apostrophe
    };

    // Replace all variants with standard apostrophe
    apostropheVariants.forEach((variant, replacement) {
      response = response.replaceAll(variant, replacement);
    });

    // Replace various Unicode quote variants with standard quotes
    final quoteVariants = {
      '"': '"', // Unicode left double quotation mark (U+201C)
      // ignore: equal_keys_in_map
      '"': '"', // Unicode right double quotation mark (U+201D)
      '«': '"', // Double left-pointing angle quotation mark
      '»': '"', // Double right-pointing angle quotation mark
      '„': '"', // Double low-9 quotation mark
      '‟': '"', // Double high-reversed-9 quotation mark
    };

    // Replace all quote variants with standard quotes
    quoteVariants.forEach((variant, replacement) {
      response = response.replaceAll(variant, replacement);
    });

    // Handle other common problematic characters
    final otherReplacements = {
      '…': '...', // Ellipsis
      '—': '-', // Em dash
      '–': '-', // En dash
      '\u200B': '', // Zero-width space
      '\u200E': '', // Left-to-right mark
      '\u200F': '', // Right-to-left mark
      '\uFEFF': '', // Zero-width no-break space
    };

    // Apply other replacements
    otherReplacements.forEach((variant, replacement) {
      response = response.replaceAll(variant, replacement);
    });

    // Unescape HTML entities
    response = _unescape.convert(response);

    // Remove any remaining non-printable characters
    response = response.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');

    // Normalize whitespace
    response = response.replaceAll(RegExp(r'\s+'), ' ').trim();

    return response;
  }

  Future<String> getChatResponse(List<Map<String, dynamic>> messages, String personality) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are talking to a Christian who is practicing sharing their faith with non-believers. They are using a personality type that matches the person they are practicing talking to. In this case, you are a $personality. Your job is to respond authentically as that personality type would when discussing Christianity.\n\nPersonality types and their characteristics:\n- skeptic: Doubts religious claims, wants evidence and logical arguments, may be scientifically minded\n- seeker: Genuinely curious about faith, open to spiritual things, but has questions and uncertainties\n- atheist: Firmly believes God does not exist, may have philosophical objections to religion\n- religious: Believes in God but from a different religious background, comparing beliefs with Christianity\n\nGuidelines:\n- Stay in character consistently\n- Use natural, conversational language\n- Ask questions that your personality type would ask\n- Raise common objections based on your personality type\n- Respond to biblical or theological points as your personality would\n- Keep responses concise (2-3 sentences when possible)\n- Never break character or acknowledge you are an AI',
            },
            ...messages,
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return _sanitizeResponse(content);
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
