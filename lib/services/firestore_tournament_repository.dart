import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tournament.dart';
import '../models/tournament_event.dart';
import 'tournament_repository.dart';

class FirestoreTournamentRepository implements TournamentRepository {
  FirestoreTournamentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<TournamentEvent>> getTournaments() async {
    final snapshot = await _firestore.collection('tournaments').get();
    final tournaments = snapshot.docs.map(_parseDoc).whereType<TournamentEvent>().toList();
    tournaments.sort((a, b) {
      final aDate = a.beginAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.beginAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return tournaments;
  }

  TournamentEvent? _parseDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    try {
      final beginAt = data['beginAtUtc'];
      final endAt = data['endAtUtc'];
      return TournamentEvent(
        id: data['id'] as String,
        leagueName: data['leagueName'] as String? ?? 'Torneo',
        leagueImageUrl: data['leagueImageUrl'] as String? ?? '',
        seasonName: data['seasonName'] as String? ?? '',
        tier: TournamentTier.values.firstWhere(
          (t) => t.name == data['tier'],
          orElse: () => TournamentTier.amateur,
        ),
        type: data['type'] as String? ?? 'online',
        prizepool: data['prizepool'] as String?,
        country: data['country'] as String?,
        beginAtUtc: beginAt is Timestamp ? beginAt.toDate().toUtc() : null,
        endAtUtc: endAt is Timestamp ? endAt.toDate().toUtc() : null,
        status: TournamentEventStatus.values.firstWhere(
          (s) => s.name == data['status'],
          orElse: () => TournamentEventStatus.upcoming,
        ),
        winnerName: data['winnerName'] as String?,
        winnerLogoUrl: data['winnerLogoUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
