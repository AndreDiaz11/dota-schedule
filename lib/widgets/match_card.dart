import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final bool isFavorite;

  const MatchCard({super.key, required this.match, required this.isFavorite});

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
                if (isFavorite) const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(_bestOfLabels[match.bestOf] ?? '', style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${match.teamA.name}  vs  ${match.teamB.name}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(time, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
