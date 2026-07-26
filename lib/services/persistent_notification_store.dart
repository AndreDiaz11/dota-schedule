import 'package:shared_preferences/shared_preferences.dart';

class PersistentNotificationStore {
  static const _key = 'persistent_notification_enabled';

  Future<bool> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
