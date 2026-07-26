import '../models/match_model.dart';

Map<DateTime, List<MatchModel>> groupMatchesByDay(List<MatchModel> matches) {
  final map = <DateTime, List<MatchModel>>{};
  for (final m in matches) {
    final local = m.startTimeLocal;
    final day = DateTime(local.year, local.month, local.day);
    map.putIfAbsent(day, () => []).add(m);
  }
  for (final list in map.values) {
    list.sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
  }
  return map;
}
