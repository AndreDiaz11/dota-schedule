import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/team.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';
import '../widgets/team_logo.dart';

class TeamProfileScreen extends ConsumerWidget {
  final Team team;

  const TeamProfileScreen({super.key, required this.team});

  static const _regionLabels = {
    Region.na: 'Norteamérica',
    Region.sa: 'Sudamérica',
    Region.eu: 'Europa',
    Region.cn: 'China',
    Region.sea: 'Sudeste Asiático',
    Region.other: 'Otra región',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final favorites = favoritesAsync.value ?? const {};
    final isFavorite = favorites.contains(team.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite ? AppColors.accentOnDark : AppColors.headerForeground,
            ),
            onPressed: () => favoritesNotifier.toggle(team.id),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TeamLogo(logoUrl: team.logoUrl, teamName: team.name, size: 72),
                const SizedBox(height: 10),
                Text(
                  team.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  _regionLabels[team.region] ?? '',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Próximos partidos',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: matchesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('No se pudieron cargar los partidos: $err')),
              data: (matches) {
                final teamMatches = matches.where((m) => m.involvesTeam(team.id)).toList()
                  ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));

                if (teamMatches.isEmpty) {
                  return const Center(
                    child: Text(
                      'Este equipo no tiene partidos programados.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: teamMatches.length,
                  itemBuilder: (context, index) => MatchCard(
                    match: teamMatches[index],
                    favoriteTeamIds: favorites,
                    onToggleFavorite: favoritesNotifier.toggle,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
