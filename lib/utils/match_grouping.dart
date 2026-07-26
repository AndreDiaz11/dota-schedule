import '../models/match_model.dart';

Map<DateTime, List<MatchModel>> groupMatchesByDay(List<MatchModel> matches) {
  final map = <DateTime, List<MatchModel>>{};
  for (final m in matches) {
    final pe = m.startTimePe;
    final day = DateTime(pe.year, pe.month, pe.day);
    map.putIfAbsent(day, () => []).add(m);
  }
  for (final list in map.values) {
    list.sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
  }
  return map;
}
