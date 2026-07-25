import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favorites_store.dart';

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  final _store = FavoritesStore();

  @override
  Future<Set<String>> build() => _store.load();

  Future<void> toggle(String teamId) async {
    final current = Set<String>.from(state.value ?? const {});
    if (!current.remove(teamId)) current.add(teamId);
    state = AsyncData(current);
    await _store.save(current);
  }

  bool isFavorite(String teamId) => state.value?.contains(teamId) ?? false;
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
