import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/group_repository.dart';
import '../services/persistent_notification_store.dart';
import 'group_provider.dart';

class NotificationLeadNotifier extends StreamNotifier<int> {
  @override
  Stream<int> build() {
    final code = ref.watch(groupCodeProvider);
    if (code == null) return Stream.value(GroupRepository.defaultLeadMinutes);

    final repo = ref.read(groupRepositoryProvider);
    return repo.watchGroup(code).map((data) {
      final minutes = data['notificationLeadMinutes'] as num?;
      return minutes?.toInt() ?? GroupRepository.defaultLeadMinutes;
    });
  }

  Future<void> setLeadMinutes(int minutes) async {
    final code = ref.read(groupCodeProvider);
    if (code == null) return;

    state = AsyncData(minutes);
    await ref.read(groupRepositoryProvider).updateLeadMinutes(code, minutes);
  }
}

final notificationLeadProvider = StreamNotifierProvider<NotificationLeadNotifier, int>(
  NotificationLeadNotifier.new,
);

class PersistentNotificationEnabledNotifier extends AsyncNotifier<bool> {
  final _store = PersistentNotificationStore();

  @override
  Future<bool> build() => _store.loadEnabled();

  Future<void> setEnabled(bool enabled) async {
    state = AsyncData(enabled);
    await _store.saveEnabled(enabled);
  }
}

final persistentNotificationEnabledProvider =
    AsyncNotifierProvider<PersistentNotificationEnabledNotifier, bool>(
  PersistentNotificationEnabledNotifier.new,
);
