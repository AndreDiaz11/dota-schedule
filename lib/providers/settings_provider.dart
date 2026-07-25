import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_store.dart';

class NotificationLeadNotifier extends AsyncNotifier<int> {
  final _store = SettingsStore();

  @override
  Future<int> build() => _store.loadLeadMinutes();

  Future<void> setLeadMinutes(int minutes) async {
    state = AsyncData(minutes);
    await _store.saveLeadMinutes(minutes);
  }
}

final notificationLeadProvider = AsyncNotifierProvider<NotificationLeadNotifier, int>(
  NotificationLeadNotifier.new,
);
