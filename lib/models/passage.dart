// models/passages.dart
import 'package:hive/hive.dart';

part 'passage.g.dart';

@HiveType(typeId: 1)
class Passage {
  @HiveField(0)
  final String text;

  Passage({required this.text});

  factory Passage.fromJson(Map<String, dynamic> json) {
    String content = json['passages'][0];
    content = _fixQuotes(content);
    return Passage(text: content);
  }

  static List<Passage> fromJsonList(Map<String, dynamic> json) {
    final List<dynamic> passageList = json['passages'];
    return passageList
        .map((passage) => Passage(
              text: _fixQuotes(passage),
            ))
        .toList();
  }

  static String _fixQuotes(String content) {
    // Check for unmatched opening quotes
    int openingQuotesCount = '“'.allMatches(content).length;
    int closingQuotesCount = '”'.allMatches(content).length;
    if (openingQuotesCount > closingQuotesCount) {
      // Add closing quote after the period but before the copyright
      int periodIndex = content.lastIndexOf('. (ESV)');
      if (periodIndex != -1) {
        content = '${content.substring(0, periodIndex + 1)}”${content.substring(periodIndex + 1)}';
      }
    } else if (closingQuotesCount > openingQuotesCount) {
      // Add opening quote at the beginning
      content = '“$content';
    }
    return content;
  }
}
