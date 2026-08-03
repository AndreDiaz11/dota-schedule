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

  const MatchCard({
    super.key,
    required this.match,
    required this.favoriteTeamIds,
  });

  static const _bestOfLabels = {
    BestOf.bo1: 'Bo1',
    BestOf.bo2: 'Bo2',
    BestOf.bo3: 'Bo3',
    BestOf.bo5: 'Bo5',
  };

  static Color _readableTextOn(Color background) {
    return background.computeLuminance() > 0.45 ? const Color(0xFF14141A) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a', 'es').format(match.startTimePe);
    final isFavorite = favoriteTeamIds.contains(match.teamA.id) || favoriteTeamIds.contains(match.teamB.id);
    final accentColor = tournamentAccentColor(match.tournament.id);

    return AppCard(
      onTap: () => context.push('/match', extra: match),
      color: isFavorite ? Color.alphaBlend(AppColors.accent.withValues(alpha: 0.12), AppColors.surface) : null,
      glowColor: match.isLive ? AppColors.live : null,
      leftAccentColor: accentColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    match.tournament.name,
                    style: TextStyle(
                      color: _readableTextOn(accentColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(time, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  match.teamA.name,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              _TeamLogoWithScore(team: match.teamA, score: match.isLive ? match.liveScore?.teamAScore : null),
              const SizedBox(width: 10),
              _CenterBadge(match: match, label: _bestOfLabels[match.bestOf] ?? ''),
              const SizedBox(width: 10),
              _TeamLogoWithScore(team: match.teamB, score: match.isLive ? match.liveScore?.teamBScore : null),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  match.teamB.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CenterBadge extends StatelessWidget {
  final MatchModel match;
  final String label;

  const _CenterBadge({required this.match, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('VS', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        if (match.isLive) const _LiveBadge() else _BoBadge(label: label),
      ],
    );
  }
}

class _BoBadge extends StatelessWidget {
  final String label;

  const _BoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.chipBackground, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TeamLogoWithScore extends StatelessWidget {
  final Team team;
  final int? score;

  const _TeamLogoWithScore({required this.team, this.score});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TeamLogo(logoUrl: team.logoUrl, teamName: team.name, region: team.region, size: 40),
        if (score != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.live,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Text(
                '$score',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }
}
