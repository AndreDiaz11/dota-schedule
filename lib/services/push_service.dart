import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'group_repository.dart';

class PushService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> registerToken(String groupCode, GroupRepository groupRepository) async {
    if (!Platform.isAndroid) return;

    try {
      await _messaging.requestPermission();

      final token = await _messaging.getToken();
      if (token != null) {
        await groupRepository.addFcmToken(groupCode, token);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        groupRepository.addFcmToken(groupCode, newToken);
      });
    } catch (_) {
      // El registro de notificaciones push es secundario: si falla (Google Play
      // Services roto/desactualizado, sin cuenta de Google, etc.) no debe impedir
      // que la app arranque ni que la vinculación por código se complete.
    }
  }
}
