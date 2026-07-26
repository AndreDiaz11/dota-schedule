import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/h2h_result.dart';
import '../models/match_model.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/team_logo.dart';

class MatchDetailScreen extends StatelessWidget {
  final MatchModel match;

  const MatchDetailScreen({super.key, required this.match});

  static const _bestOfLabels = {
    BestOf.bo1: 'Bo1',
    BestOf.bo2: 'Bo2',
    BestOf.bo3: 'Bo3',
    BestOf.bo5: 'Bo5',
  };

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE d MMM, HH:mm', 'es').format(match.startTimeLocal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle del partido')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: tierColor(match.tournament.tier), shape: BoxShape.circle),
                    ),
                    Flexible(
                      child: Text(
                        match.tournament.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (match.isLive)
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.live,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EN VIVO',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      dateLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _bestOfLabels[match.bestOf] ?? '',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _TeamColumn(name: match.teamA.name, logoUrl: match.teamA.logoUrl, region: match.teamA.region),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('VS', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: _TeamColumn(name: match.teamB.name, logoUrl: match.teamB.logoUrl, region: match.teamB.region),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Historial cara a cara',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (match.headToHead.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Todavía no hay enfrentamientos registrados entre estos equipos.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...match.headToHead.map((h2h) => _H2HTile(h2h: h2h, match: match)),
          ],
        ),
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final String name;
  final String logoUrl;
  final Region region;

  const _TeamColumn({required this.name, required this.logoUrl, required this.region});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamLogo(logoUrl: logoUrl, teamName: name, region: region, size: 56),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _H2HTile extends StatelessWidget {
  final H2HResult h2h;
  final MatchModel match;

  const _H2HTile({required this.h2h, required this.match});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy', 'es').format(h2h.dateLocal);
    final teamAWon = h2h.winnerId == match.teamA.id;
    final teamBWon = h2h.winnerId == match.teamB.id;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${h2h.tournamentName} · $date',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.teamA.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: teamAWon ? AppColors.accentOnDark : AppColors.textPrimary,
                    fontWeight: teamAWon ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '${h2h.teamAScore} - ${h2h.teamBScore}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  match.teamB.name,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: teamBWon ? AppColors.accentOnDark : AppColors.textPrimary,
                    fontWeight: teamBWon ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
