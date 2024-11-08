import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import '../models/passage.dart';
import '../models/cached_passage.dart';

class ApiService {
  final String baseUrl = 'https://api.esv.org/v3/passage/text/';
  final String apiKey = dotenv.env['ESV_API_KEY']!;
  late Box<CachedPassage> _cache;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      if (!Hive.isBoxOpen('passages_cache')) {
        _cache = await Hive.openBox<CachedPassage>('passages_cache');
      } else {
        _cache = Hive.box<CachedPassage>('passages_cache');
      }
      _isInitialized = true;
    }
  }

  Future<List<Passage>> fetchPassages(String passages, {bool includeVerseNumbers = false, bool includeFootnotes = false}) async {
    // Ensure initialization
    if (!_isInitialized) {
      await init();
    }

    // Create cache key based on all parameters
    final cacheKey = '$passages-$includeVerseNumbers-$includeFootnotes';

    // Check cache first
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      // Check if cache is still valid (less than 1 month old)
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      if (cachedData.timestamp.isAfter(monthAgo)) {
        return cachedData.passages;
      }
      // Cache is expired, delete it
      await _cache.delete(cacheKey);
    }

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
      final passageList = Passage.fromJsonList(json);

      // Store in cache
      await _cache.put(
        cacheKey,
        CachedPassage(
          key: cacheKey,
          passages: passageList,
          timestamp: DateTime.now(),
        ),
      );

      return passageList;
    } else {
      throw Exception('Failed to load passage');
    }
  }
}
