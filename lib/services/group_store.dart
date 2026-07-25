import 'package:shared_preferences/shared_preferences.dart';

class GroupStore {
  static const _key = 'group_code';

  Future<String?> loadCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
