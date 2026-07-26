import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
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

    return AppCard(
      onTap: () => context.push('/match', extra: match),
      color: isFavorite ? Color.alphaBlend(AppColors.accent.withValues(alpha: 0.12), AppColors.surface) : null,
      glowColor: match.isLive ? AppColors.live : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (match.isLive)
                  const _LiveBadge()
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
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: tierColor(match.tournament.tier), shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(
                        match.tournament.name,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.live,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'EN VIVO',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(team.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            children: [
              TeamLogo(logoUrl: team.logoUrl, teamName: team.name, region: team.region, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  key: ValueKey(isFavorite),
                  size: 20,
                  color: isFavorite ? AppColors.accentOnDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
