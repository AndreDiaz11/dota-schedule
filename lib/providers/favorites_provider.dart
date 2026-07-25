import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'group_provider.dart';

class FavoritesNotifier extends StreamNotifier<Set<String>> {
  @override
  Stream<Set<String>> build() {
    final code = ref.watch(groupCodeProvider);
    if (code == null) return Stream.value(<String>{});

    final repo = ref.read(groupRepositoryProvider);
    return repo.watchGroup(code).map((data) {
      final ids = data['favoriteTeamIds'] as List<dynamic>? ?? [];
      return ids.map((e) => e.toString()).toSet();
    });
  }

  Future<void> toggle(String teamId) async {
    final code = ref.read(groupCodeProvider);
    if (code == null) return;

    final isFavorite = state.value?.contains(teamId) ?? false;
    final repo = ref.read(groupRepositoryProvider);
    if (isFavorite) {
      await repo.removeFavorite(code, teamId);
    } else {
      await repo.addFavorite(code, teamId);
    }
  }
}

final favoritesProvider = StreamNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
