import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore {
  static const _key = 'favorite_team_ids';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> save(Set<String> teamIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, teamIds.toList());
  }
}
