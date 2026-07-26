import '../utils/peru_time.dart';
import 'h2h_result.dart';
import 'live_score.dart';
import 'team.dart';
import 'tournament.dart';

enum BestOf { bo1, bo2, bo3, bo5 }

enum MatchStatus { upcoming, running }

class MatchModel {
  final String id;
  final Tournament tournament;
  final Team teamA;
  final Team teamB;
  final DateTime startTimeUtc;
  final BestOf bestOf;
  final MatchStatus status;
  final List<H2HResult> headToHead;
  final LiveScore? liveScore;

  const MatchModel({
    required this.id,
    required this.tournament,
    required this.teamA,
    required this.teamB,
    required this.startTimeUtc,
    required this.bestOf,
    this.status = MatchStatus.upcoming,
    this.headToHead = const [],
    this.liveScore,
  });

  DateTime get startTimeLocal => startTimeUtc.toLocal();

  DateTime get startTimePe => startTimeUtc.add(peruOffset);

  bool get isLive => status == MatchStatus.running;

  bool involvesTeam(String teamId) => teamA.id == teamId || teamB.id == teamId;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'].toString(),
      tournament: Tournament.fromJson(json['tournament'] as Map<String, dynamic>),
      teamA: Team.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: Team.fromJson(json['teamB'] as Map<String, dynamic>),
      startTimeUtc: DateTime.parse(json['startTimeUtc'] as String).toUtc(),
      bestOf: BestOf.values.firstWhere(
        (b) => b.name == json['bestOf'],
        orElse: () => BestOf.bo1,
      ),
      status: MatchStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MatchStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournament': tournament.toJson(),
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
        'startTimeUtc': startTimeUtc.toIso8601String(),
        'bestOf': bestOf.name,
        'status': status.name,
      };
}
