import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/state_message.dart';
import '../widgets/team_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    return Scaffold(
      appBar: AppBar(leading: const DrawerMenuButton(), title: const Text('Favoritos')),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const StateMessage(
          icon: Icons.error_outline,
          message: 'No se pudo cargar la lista de equipos.',
        ),
        data: (teams) {
          final favorites = favoritesAsync.value ?? const {};
          final favoriteTeams = teams.where((t) => favorites.contains(t.id)).toList();

          if (favoriteTeams.isEmpty) {
            return const StateMessage(
              icon: Icons.bookmark_border,
              message: 'Todavía no marcaste ningún equipo favorito.\nHazlo desde Equipos tocando el marcador.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: favoriteTeams.length,
            itemBuilder: (context, index) {
              final team = favoriteTeams[index];
              return TeamTile(
                team: team,
                isFavorite: true,
                onToggleFavorite: () => favoritesNotifier.toggle(team.id),
              );
            },
          );
        },
      ),
    );
  }
}
