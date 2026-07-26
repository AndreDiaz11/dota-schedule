import '../models/tournament_event.dart';

abstract class TournamentRepository {
  Future<List<TournamentEvent>> getTournaments();
}
