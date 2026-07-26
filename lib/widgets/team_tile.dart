import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/team.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'team_logo.dart';

class TeamTile extends StatelessWidget {
  final Team team;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const TeamTile({
    super.key,
    required this.team,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  static const _regionLabels = {
    Region.na: 'Norteamérica',
    Region.sa: 'Sudamérica',
    Region.eu: 'Europa',
    Region.cn: 'China',
    Region.sea: 'Sudeste Asiático',
    Region.other: 'Otra región',
  };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/team', extra: team),
      child: Row(
        children: [
          TeamLogo(logoUrl: team.logoUrl, teamName: team.name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(_regionLabels[team.region] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? AppColors.accentOnDark : AppColors.textSecondary,
                ),
              ),
              onPressed: onToggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}
