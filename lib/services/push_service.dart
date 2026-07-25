import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'group_repository.dart';

class PushService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> registerToken(String groupCode, GroupRepository groupRepository) async {
    if (!Platform.isAndroid) return;

    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      await groupRepository.addFcmToken(groupCode, token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      groupRepository.addFcmToken(groupCode, newToken);
    });
  }
}
