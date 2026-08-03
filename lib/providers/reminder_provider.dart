import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/group_repository.dart';
import '../services/local_notification_service.dart';
import '../services/notified_matches_store.dart';
import '../services/persistent_notification_service.dart';
import 'favorites_provider.dart';
import 'matches_provider.dart';
import 'settings_provider.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

final notifiedMatchesStoreProvider = Provider<NotifiedMatchesStore>((ref) {
  return NotifiedMatchesStore();
});

final matchReminderCheckerProvider = Provider<void>((ref) {
  if (!Platform.isWindows) return;

  Future<void> check() async {
    final favorites = ref.read(favoritesProvider).value ?? const <String>{};
    if (favorites.isEmpty) return;

    final leadMinutes = ref.read(notificationLeadProvider).value ?? GroupRepository.defaultLeadMinutes;
    final store = ref.read(notifiedMatchesStoreProvider);
    final notified = await store.load();

    final matches = await ref.read(matchesProvider.future);
    final now = DateTime.now().toUtc();
    var changed = false;

    for (final match in matches) {
      if (notified.contains(match.id)) continue;
      final isFavorite = favorites.contains(match.teamA.id) || favorites.contains(match.teamB.id);
      if (!isFavorite) continue;

      final minutesUntil = match.startTimeUtc.difference(now).inMinutes;
      if (minutesUntil < 0 || minutesUntil > leadMinutes) continue;

      await ref.read(localNotificationServiceProvider).showMatchReminder(
            title: '¡Ya casi empieza!',
            body: '${match.teamA.name} vs ${match.teamB.name} arranca en $minutesUntil min · ${match.tournament.name}',
          );
      notified.add(match.id);
      changed = true;
    }

    if (changed) await store.save(notified);
  }

  final timer = Timer.periodic(const Duration(minutes: 1), (_) => check());
  check();

  ref.onDispose(timer.cancel);
});

final persistentNotificationServiceProvider = Provider<PersistentNotificationService>((ref) {
  return PersistentNotificationService();
});

final persistentNotificationSyncProvider = Provider<void>((ref) {
  if (!Platform.isAndroid) return;

  Future<void> sync() async {
    final service = ref.read(persistentNotificationServiceProvider);
    final enabled = ref.read(persistentNotificationEnabledProvider).value ?? true;
    if (!enabled) {
      await service.stop();
      return;
    }

    final favorites = ref.read(favoritesProvider).value ?? const <String>{};
    if (favorites.isEmpty) {
      await service.stop();
      return;
    }

    final matches = await ref.read(matchesProvider.future);
    final favoriteMatches = matches.where(
      (m) => favorites.contains(m.teamA.id) || favorites.contains(m.teamB.id),
    ).toList();

    if (favoriteMatches.isEmpty) {
      await service.stop();
      return;
    }

    final leadMinutes = ref.read(notificationLeadProvider).value ?? GroupRepository.defaultLeadMinutes;
    await service.sync(favoriteMatches, leadMinutes: leadMinutes);
  }

  final timer = Timer.periodic(const Duration(minutes: 1), (_) => sync());
  sync();

  ref.listen(persistentNotificationEnabledProvider, (_, _) => sync());
  ref.listen(favoritesProvider, (_, _) => sync());
  ref.listen(notificationLeadProvider, (_, _) => sync());

  ref.onDispose(timer.cancel);
});
