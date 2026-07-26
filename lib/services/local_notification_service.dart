import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      windows: WindowsInitializationSettings(
        appName: 'Pulse',
        appUserModelId: 'com.dotaschedule.dota_schedule',
        guid: '5a6f3f2e-9b1a-4b8a-9f0a-7c2f6e1d4a3b',
      ),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> showMatchReminder({required String title, required String body}) async {
    await _ensureInitialized();
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(),
    );
  }
}
