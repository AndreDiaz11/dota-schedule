import 'package:dio/dio.dart';

import '../models/match_model.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import 'match_repository.dart';

class PandaScoreMatchRepository implements MatchRepository {
  PandaScoreMatchRepository(this._apiKey);

  final String _apiKey;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.pandascore.co'));

  List<MatchModel>? _cachedMatches;

  static const _regionByCountry = {
    'US': Region.na, 'CA': Region.na, 'MX': Region.na,
    'BR': Region.sa, 'PE': Region.sa, 'AR': Region.sa, 'CL': Region.sa,
    'CO': Region.sa, 'EC': Region.sa, 'UY': Region.sa, 'PY': Region.sa,
    'BO': Region.sa, 'VE': Region.sa,
    'RU': Region.eu, 'UA': Region.eu, 'GR': Region.eu, 'RS': Region.eu,
    'DE': Region.eu, 'FR': Region.eu, 'ES': Region.eu, 'PT': Region.eu,
    'IT': Region.eu, 'PL': Region.eu, 'GB': Region.eu, 'UK': Region.eu,
    'SE': Region.eu, 'NO': Region.eu, 'FI': Region.eu, 'DK': Region.eu,
    'NL': Region.eu, 'BE': Region.eu, 'CZ': Region.eu, 'SK': Region.eu,
    'RO': Region.eu, 'BG': Region.eu, 'KZ': Region.eu,
    'CN': Region.cn,
    'PH': Region.sea, 'ID': Region.sea, 'MY': Region.sea, 'TH': Region.sea,
    'VN': Region.sea, 'SG': Region.sea, 'MM': Region.sea,
  };

  Future<List<MatchModel>> _fetchUpcoming() async {
    if (_cachedMatches != null) return _cachedMatches!;

    final response = await _dio.get(
      '/dota2/matches/upcoming',
      queryParameters: {'per_page': 100, 'sort': 'begin_at'},
      options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
    );

    final data = response.data as List<dynamic>;
    final matches = <MatchModel>[];
    for (final raw in data) {
      final match = _parseMatch(raw as Map<String, dynamic>);
      if (match != null) matches.add(match);
    }
    matches.sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));

    _cachedMatches = matches;
    return matches;
  }

  MatchModel? _parseMatch(Map<String, dynamic> raw) {
    final opponents = raw['opponents'] as List<dynamic>? ?? [];
    if (opponents.length < 2) return null;

    final teamAJson = (opponents[0] as Map<String, dynamic>)['opponent'] as Map<String, dynamic>?;
    final teamBJson = (opponents[1] as Map<String, dynamic>)['opponent'] as Map<String, dynamic>?;
    if (teamAJson == null || teamBJson == null) return null;

    final scheduledAt = raw['scheduled_at'] ?? raw['begin_at'];
    if (scheduledAt == null) return null;

    final league = raw['league'] as Map<String, dynamic>?;
    final tournament = raw['tournament'] as Map<String, dynamic>?;

    return MatchModel(
      id: raw['id'].toString(),
      tournament: Tournament(
        id: (league?['id'] ?? tournament?['id'] ?? raw['id']).toString(),
        name: (league?['name'] as String?) ?? (tournament?['name'] as String?) ?? 'Torneo',
        tier: _mapTier(tournament?['tier'] as String?),
      ),
      teamA: _parseTeam(teamAJson),
      teamB: _parseTeam(teamBJson),
      startTimeUtc: DateTime.parse(scheduledAt as String).toUtc(),
      bestOf: _mapBestOf(raw['number_of_games'] as int?),
    );
  }

  Team _parseTeam(Map<String, dynamic> json) {
    return Team(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? (json['acronym'] as String?) ?? 'TBD',
      logoUrl: (json['image_url'] as String?) ?? '',
      region: _mapRegion(json['location'] as String?),
    );
  }

  TournamentTier _mapTier(String? tier) {
    switch (tier) {
      case 's':
      case 'a':
        return TournamentTier.tier1;
      case 'b':
        return TournamentTier.tier2;
      case 'c':
        return TournamentTier.tier3;
      case 'd':
        return TournamentTier.qualifier;
      default:
        return TournamentTier.amateur;
    }
  }

  BestOf _mapBestOf(int? games) {
    switch (games) {
      case 1:
        return BestOf.bo1;
      case 2:
        return BestOf.bo2;
      case 3:
        return BestOf.bo3;
      case 5:
        return BestOf.bo5;
      default:
        return BestOf.bo1;
    }
  }

  Region _mapRegion(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) return Region.other;
    return _regionByCountry[countryCode.toUpperCase()] ?? Region.other;
  }

  @override
  Future<List<MatchModel>> getUpcomingMatches() => _fetchUpcoming();

  @override
  Future<List<Team>> getTeams() async {
    final matches = await _fetchUpcoming();
    final teamsById = <String, Team>{};
    for (final m in matches) {
      teamsById[m.teamA.id] = m.teamA;
      teamsById[m.teamB.id] = m.teamB;
    }
    final teams = teamsById.values.toList();
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }
}
