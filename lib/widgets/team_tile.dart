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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/team', extra: team),
      child: Row(
        children: [
          TeamLogo(logoUrl: team.logoUrl, teamName: team.name, region: team.region, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: regionColor(team.region), shape: BoxShape.circle),
                    ),
                    Flexible(
                      child: Text(
                        regionLabel(team.region),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
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
