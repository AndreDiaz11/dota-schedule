import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import 'team_logo.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final Set<String> favoriteTeamIds;
  final ValueChanged<String> onToggleFavorite;

  const MatchCard({
    super.key,
    required this.match,
    required this.favoriteTeamIds,
    required this.onToggleFavorite,
  });

  static const _bestOfLabels = {
    BestOf.bo1: 'Bo1',
    BestOf.bo2: 'Bo2',
    BestOf.bo3: 'Bo3',
    BestOf.bo5: 'Bo5',
  };

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm', 'es').format(match.startTimeLocal);
    final isFavorite = favoriteTeamIds.contains(match.teamA.id) || favoriteTeamIds.contains(match.teamB.id);

    return InkWell(
      onTap: () => context.push('/match', extra: match),
      child: Ink(
        decoration: BoxDecoration(
          color: isFavorite ? AppColors.accent.withValues(alpha: 0.12) : AppColors.surface,
          border: const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'EN VIVO',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _bestOfLabels[match.bestOf] ?? '',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.tournament.name,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _TeamRow(team: match.teamA, isFavorite: favoriteTeamIds.contains(match.teamA.id), onTap: onToggleFavorite),
                  const SizedBox(height: 6),
                  _TeamRow(team: match.teamB, isFavorite: favoriteTeamIds.contains(match.teamB.id), onTap: onToggleFavorite),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final Team team;
  final bool isFavorite;
  final ValueChanged<String> onTap;

  const _TeamRow({required this.team, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(team.id),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            TeamLogo(logoUrl: team.logoUrl, teamName: team.name, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                team.name,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: isFavorite ? AppColors.accentOnDark : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
