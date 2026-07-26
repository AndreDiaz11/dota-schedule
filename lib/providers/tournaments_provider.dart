import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tournament_event.dart';
import 'repository_provider.dart';

final tournamentsProvider = FutureProvider<List<TournamentEvent>>((ref) {
  return ref.watch(tournamentRepositoryProvider).getTournaments();
});
