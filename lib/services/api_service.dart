// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/passage.dart';

class ApiService {
  final String baseUrl = 'https://api.esv.org/v3/passage/text/';
  final String apiKey = '55f2db97422b5bf8471448dd1e306287b71a1aad';

  Future<List<Passage>> fetchPassages(String passages, {bool includeVerseNumbers = false, bool includeFootnotes = false}) async {
    final queryParameters = {
      'q': passages,
      'include-headings': 'false',
      'include-verse-numbers': includeVerseNumbers.toString(),
      'include-footnotes': includeFootnotes.toString(),
      'include-heading-horizontal-lines': 'true',
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Token $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Passage.fromJsonList(json);
    } else {
      throw Exception('Failed to load passage');
    }
  }
}
