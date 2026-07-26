import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/news_repository.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(FirebaseFirestore.instance);
});

final newsProvider = FutureProvider((ref) {
  return ref.watch(newsRepositoryProvider).getLatestNews();
});
