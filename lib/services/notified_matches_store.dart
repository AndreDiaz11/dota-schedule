import 'package:shared_preferences/shared_preferences.dart';

class NotifiedMatchesStore {
  static const _key = 'notified_match_ids';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
