import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/team.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/state_message.dart';
import '../widgets/team_tile.dart';

class TeamSelectorScreen extends ConsumerStatefulWidget {
  const TeamSelectorScreen({super.key});

  @override
  ConsumerState<TeamSelectorScreen> createState() => _TeamSelectorScreenState();
}

class _TeamSelectorScreenState extends ConsumerState<TeamSelectorScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Region? _regionFilter;

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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Wrap(
              spacing: 0,
              runSpacing: 4,
              children: [
                _RegionChip(
                  label: 'Todos',
                  color: AppColors.accent,
                  selected: _regionFilter == null,
                  onTap: () => setState(() => _regionFilter = null),
                ),
                for (final region in Region.values)
                  _RegionChip(
                    label: regionLabel(region),
                    color: regionColor(region),
                    selected: _regionFilter == region,
                    onTap: () => setState(() => _regionFilter = region),
                  ),
              ],
            ),
          ),
          Expanded(
            child: teamsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const StateMessage(
                icon: Icons.error_outline,
                message: 'No se pudo cargar la lista de equipos.',
              ),
              data: (teams) {
                final filtered = teams
                    .where((t) => _query.isEmpty || t.name.toLowerCase().contains(_query))
                    .where((t) => _regionFilter == null || t.region == _regionFilter)
                    .toList();
                final favorites = favoritesAsync.value ?? const {};

                if (filtered.isEmpty) {
                  return const StateMessage(
                    icon: Icons.search_off,
                    message: 'Ningún equipo coincide con la búsqueda.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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

class _RegionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RegionChip({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.22) : AppColors.chipBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? color : Colors.transparent, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
