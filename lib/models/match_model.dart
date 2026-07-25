import 'team.dart';
import 'tournament.dart';

enum BestOf { bo1, bo2, bo3, bo5 }

class MatchModel {
  final String id;
  final Tournament tournament;
  final Team teamA;
  final Team teamB;
  final DateTime startTimeUtc;
  final BestOf bestOf;

  const MatchModel({
    required this.id,
    required this.tournament,
    required this.teamA,
    required this.teamB,
    required this.startTimeUtc,
    required this.bestOf,
  });

  DateTime get startTimeLocal => startTimeUtc.toLocal();

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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournament': tournament.toJson(),
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
        'startTimeUtc': startTimeUtc.toIso8601String(),
        'bestOf': bestOf.name,
      };
}
