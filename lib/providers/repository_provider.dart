import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_match_repository.dart';
import '../services/firestore_tournament_repository.dart';
import '../services/match_repository.dart';
import '../services/tournament_repository.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return FirestoreMatchRepository(FirebaseFirestore.instance);
});

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return FirestoreTournamentRepository(FirebaseFirestore.instance);
});
