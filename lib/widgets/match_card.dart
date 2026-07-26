import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../models/team.dart';

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
    final theme = Theme.of(context);
    final time = DateFormat('EEE d MMM · HH:mm', 'es').format(match.startTimeLocal);
    final isFavorite = favoriteTeamIds.contains(match.teamA.id) || favoriteTeamIds.contains(match.teamB.id);

    return Card(
      color: isFavorite ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.tournament.name,
                    style: theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(_bestOfLabels[match.bestOf] ?? '', style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _TeamButton(team: match.teamA, isFavorite: favoriteTeamIds.contains(match.teamA.id), onTap: onToggleFavorite),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('vs')),
                _TeamButton(team: match.teamB, isFavorite: favoriteTeamIds.contains(match.teamB.id), onTap: onToggleFavorite),
              ],
            ),
            const SizedBox(height: 4),
            Text(time, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _TeamButton extends StatelessWidget {
  final Team team;
  final bool isFavorite;
  final ValueChanged<String> onTap;

  const _TeamButton({required this.team, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => onTap(team.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 18,
              color: isFavorite ? Colors.amber : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              team.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
