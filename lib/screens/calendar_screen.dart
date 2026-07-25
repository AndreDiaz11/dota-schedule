import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../widgets/match_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _onlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilterChip(
              label: const Text('Solo favoritos'),
              selected: _onlyFavorites,
              onSelected: (v) => setState(() => _onlyFavorites = v),
            ),
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('No se pudo cargar el calendario: $err')),
        data: (matches) {
          final favorites = favoritesAsync.value ?? const {};
          final visible = _onlyFavorites
              ? matches.where((m) => favorites.contains(m.teamA.id) || favorites.contains(m.teamB.id)).toList()
              : matches;

          if (visible.isEmpty) {
            return const Center(child: Text('No hay partidos próximos para mostrar.'));
          }

          final grouped = _groupByDay(visible);
          final days = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final dayMatches = grouped[day]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('EEEE d MMMM', 'es').format(day),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  for (final m in dayMatches)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MatchCard(
                        match: m,
                        isFavorite: favorites.contains(m.teamA.id) || favorites.contains(m.teamB.id),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, List<MatchModel>> _groupByDay(List<MatchModel> matches) {
    final map = <DateTime, List<MatchModel>>{};
    for (final m in matches) {
      final local = m.startTimeLocal;
      final day = DateTime(local.year, local.month, local.day);
      map.putIfAbsent(day, () => []).add(m);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
    }
    return map;
  }
}
