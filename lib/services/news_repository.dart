import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/news_item.dart';

class NewsRepository {
  NewsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<NewsItem>> getLatestNews() async {
    final snapshot = await _firestore
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .limit(60)
        .get();
    return snapshot.docs.map(_parseDoc).whereType<NewsItem>().toList();
  }

  NewsItem? _parseDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final publishedAt = data['publishedAt'];
    if (publishedAt is! Timestamp) return null;

    try {
      return NewsItem(
        id: doc.id,
        title: data['title'] as String? ?? 'Sin título',
        link: data['link'] as String,
        source: data['source'] as String? ?? '',
        summary: data['summary'] as String? ?? '',
        imageUrl: data['imageUrl'] as String?,
        publishedAtUtc: publishedAt.toDate().toUtc(),
      );
    } catch (_) {
      return null;
    }
  }
}
