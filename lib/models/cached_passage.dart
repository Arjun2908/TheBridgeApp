import 'package:hive/hive.dart';
import 'passage.dart';

part 'cached_passage.g.dart';

@HiveType(typeId: 2)
class CachedPassage {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final List<Passage> passages;

  @HiveField(2)
  final DateTime timestamp;

  CachedPassage({
    required this.key,
    required this.passages,
    required this.timestamp,
  });
}
