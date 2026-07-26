class NewsItem {
  final String id;
  final String title;
  final String link;
  final String source;
  final String summary;
  final String? imageUrl;
  final DateTime publishedAtUtc;

  const NewsItem({
    required this.id,
    required this.title,
    required this.link,
    required this.source,
    required this.summary,
    required this.imageUrl,
    required this.publishedAtUtc,
  });

  DateTime get publishedAtLocal => publishedAtUtc.toLocal();
}
