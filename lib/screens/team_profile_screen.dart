import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/team.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';
import '../widgets/state_message.dart';
import '../widgets/team_logo.dart';

class TeamProfileScreen extends ConsumerWidget {
  final Team team;

  const TeamProfileScreen({super.key, required this.team});

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
      body: SafeArea(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TeamLogo(logoUrl: team.logoUrl, teamName: team.name, region: team.region, size: 72),
                const SizedBox(height: 10),
                Text(
                  team.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: regionColor(team.region), shape: BoxShape.circle),
                    ),
                    Text(
                      regionLabel(team.region),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
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
              error: (err, _) => const StateMessage(
                icon: Icons.error_outline,
                message: 'No se pudieron cargar los partidos.',
              ),
              data: (matches) {
                final teamMatches = matches.where((m) => m.involvesTeam(team.id)).toList()
                  ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));

                if (teamMatches.isEmpty) {
                  return const StateMessage(
                    icon: Icons.event_busy,
                    message: 'Este equipo no tiene partidos programados.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
      ),
    );
  }
}
