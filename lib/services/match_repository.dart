import '../models/match_model.dart';
import '../models/team.dart';

abstract class MatchRepository {
  Future<List<MatchModel>> getUpcomingMatches();
  Future<List<Team>> getTeams();
}
