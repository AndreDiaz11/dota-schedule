import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/team_tile.dart';

class TeamSelectorScreen extends ConsumerStatefulWidget {
  const TeamSelectorScreen({super.key});

  @override
  ConsumerState<TeamSelectorScreen> createState() => _TeamSelectorScreenState();
}

class _TeamSelectorScreenState extends ConsumerState<TeamSelectorScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    return Scaffold(
      appBar: AppBar(leading: const DrawerMenuButton(), title: const Text('Equipos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar equipo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: teamsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('No se pudo cargar la lista de equipos: $err')),
              data: (teams) {
                final filtered = _query.isEmpty
                    ? teams
                    : teams.where((t) => t.name.toLowerCase().contains(_query)).toList();
                final favorites = favoritesAsync.value ?? const {};

                if (filtered.isEmpty) {
                  return const Center(child: Text('Ningún equipo coincide con la búsqueda.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final team = filtered[index];
                    return TeamTile(
                      team: team,
                      isFavorite: favorites.contains(team.id),
                      onToggleFavorite: () => favoritesNotifier.toggle(team.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
