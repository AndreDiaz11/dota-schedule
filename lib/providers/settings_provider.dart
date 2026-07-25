import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/group_repository.dart';
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
