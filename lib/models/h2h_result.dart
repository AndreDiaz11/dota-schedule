import '../utils/peru_time.dart';

class H2HResult {
  final DateTime dateUtc;
  final String tournamentName;
  final int teamAScore;
  final int teamBScore;
  final String? winnerId;

  const H2HResult({
    required this.dateUtc,
    required this.tournamentName,
    required this.teamAScore,
    required this.teamBScore,
    required this.winnerId,
  });

  DateTime get dateLocal => dateUtc.toLocal();

  DateTime get datePe => dateUtc.add(peruOffset);
}
