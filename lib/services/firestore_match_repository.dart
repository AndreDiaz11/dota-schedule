import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import 'match_repository.dart';

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<MatchModel>> getUpcomingMatches() async {
    final snapshot = await _firestore.collection('matches').orderBy('startTimeUtc').get();
    return snapshot.docs.map(_parseDoc).whereType<MatchModel>().toList();
  }

  @override
  Future<List<Team>> getTeams() async {
    final matches = await getUpcomingMatches();
    final teamsById = <String, Team>{};
    for (final m in matches) {
      teamsById[m.teamA.id] = m.teamA;
      teamsById[m.teamB.id] = m.teamB;
    }
    final teams = teamsById.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  MatchModel? _parseDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final startTime = data['startTimeUtc'];
    if (startTime is! Timestamp) return null;

    try {
      return MatchModel(
        id: data['id'] as String,
        tournament: Tournament.fromJson({
          'id': data['tournamentId'],
          'name': data['tournamentName'],
          'tier': data['tier'],
        }),
        teamA: Team.fromJson(data['teamA'] as Map<String, dynamic>),
        teamB: Team.fromJson(data['teamB'] as Map<String, dynamic>),
        startTimeUtc: startTime.toDate().toUtc(),
        bestOf: BestOf.values.firstWhere(
          (b) => b.name == data['bestOf'],
          orElse: () => BestOf.bo1,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
