import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _onlyFavorites = false;
  late DateTime _selectedDay;
  late final List<DateTime> _strip;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDay = today;
    _strip = List.generate(14, (i) => today.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
          final favoritesNotifier = ref.read(favoritesProvider.notifier);
          final byDay = _groupByDay(matches);

          final dayMatches = (byDay[_selectedDay] ?? const <MatchModel>[])
              .where((m) => !_onlyFavorites || favorites.contains(m.teamA.id) || favorites.contains(m.teamB.id))
              .toList();

          return Column(
            children: [
              _DateStrip(
                days: _strip,
                selected: _selectedDay,
                daysWithMatches: byDay.keys.toSet(),
                onSelect: (day) => setState(() => _selectedDay = day),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: dayMatches.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay partidos ese día.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: dayMatches.length,
                        itemBuilder: (context, index) => MatchCard(
                          match: dayMatches[index],
                          favoriteTeamIds: favorites,
                          onToggleFavorite: favoritesNotifier.toggle,
                        ),
                      ),
              ),
            ],
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

class _DateStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selected;
  final Set<DateTime> daysWithMatches;
  final ValueChanged<DateTime> onSelect;

  const _DateStrip({
    required this.days,
    required this.selected,
    required this.daysWithMatches,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selected;
          final hasMatches = daysWithMatches.contains(day);

          return InkWell(
            onTap: () => onSelect(day),
            child: Container(
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'es').format(day),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (hasMatches)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.accentOnDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
