import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const _leadMinutesKey = 'notification_lead_minutes';
  static const defaultLeadMinutes = 30;

  Future<int> loadLeadMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_leadMinutesKey) ?? defaultLeadMinutes;
  }

  Future<void> saveLeadMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_leadMinutesKey, minutes);
  }
}
