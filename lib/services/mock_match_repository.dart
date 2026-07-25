import '../models/match_model.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import 'match_repository.dart';

class MockMatchRepository implements MatchRepository {
  static const _teams = [
    Team(id: 't1', name: 'Team Spirit', logoUrl: '', region: Region.eu),
    Team(id: 't2', name: 'Gaimin Gladiators', logoUrl: '', region: Region.eu),
    Team(id: 't3', name: 'PSG Quest', logoUrl: '', region: Region.eu),
    Team(id: 't4', name: 'Tundra Esports', logoUrl: '', region: Region.eu),
    Team(id: 't5', name: 'Team Falcons', logoUrl: '', region: Region.sea),
    Team(id: 't6', name: 'BetBoom Team', logoUrl: '', region: Region.eu),
    Team(id: 't7', name: 'Xtreme Gaming', logoUrl: '', region: Region.cn),
    Team(id: 't8', name: 'Azure Ray', logoUrl: '', region: Region.cn),
    Team(id: 't9', name: 'Talon Esports', logoUrl: '', region: Region.sea),
    Team(id: 't10', name: 'Shopify Rebellion', logoUrl: '', region: Region.na),
    Team(id: 't11', name: 'beastcoast', logoUrl: '', region: Region.sa),
    Team(id: 't12', name: 'Nigma Galaxy', logoUrl: '', region: Region.eu),
  ];

  static const _tournaments = [
    Tournament(id: 'tour1', name: 'ESL One Bangkok', tier: TournamentTier.tier1),
    Tournament(id: 'tour2', name: 'DPC EU Division I', tier: TournamentTier.tier2),
    Tournament(id: 'tour3', name: 'Riyadh Masters', tier: TournamentTier.tier1),
    Tournament(id: 'tour4', name: 'Clasificatorio Regional SA', tier: TournamentTier.qualifier),
    Tournament(id: 'tour5', name: 'Copa Comunitaria SEA', tier: TournamentTier.amateur),
  ];

  @override
  Future<List<Team>> getTeams() async => _teams;

  @override
  Future<List<MatchModel>> getUpcomingMatches() async {
    final now = DateTime.now().toUtc();
    final pairs = [
      (0, 1, 0, const Duration(hours: 3)),
      (2, 3, 1, const Duration(hours: 8)),
      (4, 5, 2, const Duration(days: 1, hours: 2)),
      (6, 7, 0, const Duration(days: 1, hours: 6)),
      (8, 9, 3, const Duration(days: 2)),
      (10, 11, 4, const Duration(days: 2, hours: 5)),
      (1, 3, 2, const Duration(days: 3)),
      (0, 6, 0, const Duration(days: 4, hours: 1)),
      (5, 9, 4, const Duration(days: 4, hours: 9)),
      (7, 11, 1, const Duration(days: 5)),
    ];

    return [
      for (var i = 0; i < pairs.length; i++)
        MatchModel(
          id: 'm$i',
          tournament: _tournaments[pairs[i].$3],
          teamA: _teams[pairs[i].$1],
          teamB: _teams[pairs[i].$2],
          startTimeUtc: now.add(pairs[i].$4),
          bestOf: i.isEven ? BestOf.bo3 : BestOf.bo1,
        ),
    ];
  }
}
