import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/team.dart';
import '../theme/app_theme.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: ListTile(
        onTap: () => context.push('/team', extra: team),
        leading: TeamLogo(logoUrl: team.logoUrl, teamName: team.name, size: 36),
        title: Text(team.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(_regionLabels[team.region] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.bookmark : Icons.bookmark_border,
            color: isFavorite ? AppColors.accentOnDark : AppColors.textSecondary,
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}
