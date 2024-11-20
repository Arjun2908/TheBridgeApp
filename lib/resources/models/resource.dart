class Resource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String url;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
  });

  bool get isStudyGuidePdf => type == ResourceType.studyGuide && (url.toLowerCase().endsWith('.pdf') || url.startsWith('gs://'));

  bool get isStudyGuideWeb => type == ResourceType.studyGuide && !isStudyGuidePdf;
}

enum ResourceType {
  video,
  studyGuide,
}
