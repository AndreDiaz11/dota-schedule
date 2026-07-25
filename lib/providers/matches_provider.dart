import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_model.dart';
import '../models/team.dart';
import 'repository_provider.dart';

final matchesProvider = FutureProvider<List<MatchModel>>((ref) {
  return ref.watch(matchRepositoryProvider).getUpcomingMatches();
});

final teamsProvider = FutureProvider<List<Team>>((ref) {
  return ref.watch(matchRepositoryProvider).getTeams();
});
