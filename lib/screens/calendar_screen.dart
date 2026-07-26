import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/match_card.dart';
import '../widgets/state_message.dart';

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
        leading: const DrawerMenuButton(),
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
        error: (err, _) => const StateMessage(
          icon: Icons.error_outline,
          message: 'No se pudo cargar el calendario.',
        ),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: dayMatches.isEmpty
                      ? const StateMessage(
                          key: ValueKey('empty'),
                          icon: Icons.event_busy,
                          message: 'No hay partidos ese día.',
                        )
                      : ListView.builder(
                          key: ValueKey(_selectedDay),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: dayMatches.length,
                          itemBuilder: (context, index) => MatchCard(
                            match: dayMatches[index],
                            favoriteTeamIds: favorites,
                            onToggleFavorite: favoritesNotifier.toggle,
                          ),
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

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(day),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      child: Text(DateFormat('EEE', 'es').format(day)),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      child: Text('${day.day}'),
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
            ),
          );
        },
      ),
    );
  }
}
