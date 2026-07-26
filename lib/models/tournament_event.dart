import '../utils/peru_time.dart';
import 'tournament.dart';

enum TournamentEventStatus { running, upcoming, past }

class TournamentEvent {
  final String id;
  final String leagueName;
  final String leagueImageUrl;
  final String seasonName;
  final TournamentTier tier;
  final String type;
  final String? prizepool;
  final String? country;
  final DateTime? beginAtUtc;
  final DateTime? endAtUtc;
  final TournamentEventStatus status;
  final String? winnerName;
  final String? winnerLogoUrl;

  const TournamentEvent({
    required this.id,
    required this.leagueName,
    required this.leagueImageUrl,
    required this.seasonName,
    required this.tier,
    required this.type,
    required this.prizepool,
    required this.country,
    required this.beginAtUtc,
    required this.endAtUtc,
    required this.status,
    required this.winnerName,
    required this.winnerLogoUrl,
  });

  bool get isOffline => type == 'offline';

  DateTime? get beginAtPe => beginAtUtc?.add(peruOffset);

  DateTime? get endAtPe => endAtUtc?.add(peruOffset);
}
