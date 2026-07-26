import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/h2h_result.dart';
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
    final snapshot = await _firestore.collection('teams').get();
    final teams = snapshot.docs
        .map((doc) {
          try {
            return Team.fromJson(doc.data());
          } catch (_) {
            return null;
          }
        })
        .whereType<Team>()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
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
        status: MatchStatus.values.firstWhere(
          (s) => s.name == data['status'],
          orElse: () => MatchStatus.upcoming,
        ),
        headToHead: _parseHeadToHead(data['headToHead']),
      );
    } catch (_) {
      return null;
    }
  }

  List<H2HResult> _parseHeadToHead(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((entry) {
          final date = entry['dateUtc'];
          if (date is! Timestamp) return null;
          return H2HResult(
            dateUtc: date.toDate().toUtc(),
            tournamentName: entry['tournamentName'] as String? ?? 'Torneo',
            teamAScore: (entry['teamAScore'] as num?)?.toInt() ?? 0,
            teamBScore: (entry['teamBScore'] as num?)?.toInt() ?? 0,
            winnerId: entry['winnerId'] as String?,
          );
        })
        .whereType<H2HResult>()
        .toList();
  }
}
