import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/team.dart';
import '../models/tournament.dart';
import '../models/tournament_event.dart';
import '../providers/tournaments_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/state_message.dart';
import '../widgets/team_logo.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen> {
  TournamentEventStatus _status = TournamentEventStatus.running;

  static const _tabLabels = {
    TournamentEventStatus.running: 'En curso',
    TournamentEventStatus.upcoming: 'Próximos',
    TournamentEventStatus.past: 'Finalizados',
  };

  static const _emptyMessages = {
    TournamentEventStatus.running: 'No hay torneos en curso ahora mismo.',
    TournamentEventStatus.upcoming: 'No hay torneos próximos por ahora.',
    TournamentEventStatus.past: 'Todavía no hay torneos finalizados.',
  };

  @override
  Widget build(BuildContext context) {
    final tournamentsAsync = ref.watch(tournamentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const DrawerMenuButton(), title: const Text('Torneos')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  for (final status in TournamentEventStatus.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _StatusTab(
                          label: _tabLabels[status]!,
                          selected: _status == status,
                          onTap: () => setState(() => _status = status),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: tournamentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => const StateMessage(
                  icon: Icons.error_outline,
                  message: 'No se pudieron cargar los torneos.',
                ),
                data: (tournaments) {
                  final filtered = tournaments.where((t) => t.status == _status).toList();
                  if (_status == TournamentEventStatus.upcoming) {
                    filtered.sort((a, b) => (a.beginAtUtc ?? DateTime(0)).compareTo(b.beginAtUtc ?? DateTime(0)));
                  } else {
                    filtered.sort((a, b) => (b.endAtUtc ?? b.beginAtUtc ?? DateTime(0))
                        .compareTo(a.endAtUtc ?? a.beginAtUtc ?? DateTime(0)));
                  }

                  if (filtered.isEmpty) {
                    return StateMessage(icon: Icons.emoji_events_outlined, message: _emptyMessages[_status]!);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _TournamentCard(tournament: filtered[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.chipBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentEvent tournament;

  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'es');
    final begin = tournament.beginAtPe;
    final end = tournament.endAtPe;
    String? dateLabel;
    if (begin != null && end != null) {
      dateLabel = '${dateFormat.format(begin)} – ${dateFormat.format(end)}';
    } else if (begin != null) {
      dateLabel = dateFormat.format(begin);
    }

    return AppCard(
      leftAccentColor: tierColor(tournament.tier),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tournament.leagueImageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: tournament.leagueImageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => const SizedBox(width: 36, height: 36),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.leagueName,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (tournament.seasonName.isNotEmpty)
                      Text(
                        tournament.seasonName,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                icon: Icons.emoji_events,
                label: switch (tournament.tier) {
                  TournamentTier.tier1 => 'Tier 1',
                  TournamentTier.tier2 => 'Tier 2',
                  TournamentTier.tier3 => 'Tier 3',
                  TournamentTier.qualifier => 'Clasificatorio',
                  TournamentTier.amateur => 'Amateur',
                },
                color: tierColor(tournament.tier),
              ),
              _InfoChip(
                icon: tournament.isOffline ? Icons.stadium : Icons.wifi,
                label: tournament.isOffline ? 'Presencial' : 'En línea',
                color: AppColors.chipBackground,
              ),
              if (tournament.country != null)
                _InfoChip(icon: Icons.public, label: tournament.country!, color: AppColors.chipBackground),
              if (tournament.prizepool != null)
                _InfoChip(icon: Icons.payments, label: tournament.prizepool!, color: AppColors.chipBackground),
            ],
          ),
          if (dateLabel != null) ...[
            const SizedBox(height: 8),
            Text(dateLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          if (tournament.status == TournamentEventStatus.past && tournament.winnerName != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.military_tech, color: AppColors.live, size: 18),
                const SizedBox(width: 6),
                const Text('Ganador: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                if (tournament.winnerLogoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: TeamLogo(
                      logoUrl: tournament.winnerLogoUrl!,
                      teamName: tournament.winnerName!,
                      region: Region.other,
                      size: 20,
                    ),
                  ),
                Flexible(
                  child: Text(
                    tournament.winnerName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.chipBackground, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color == AppColors.chipBackground ? AppColors.textSecondary : color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
