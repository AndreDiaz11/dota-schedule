import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../utils/match_grouping.dart';
import '../utils/peru_time.dart';
import '../widgets/drawer_menu_button.dart';
import '../widgets/match_card.dart';
import '../widgets/month_calendar.dart';
import '../widgets/state_message.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  late DateTime _month;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = peruNow();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const DrawerMenuButton(), title: const Text('Seguimiento')),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const StateMessage(
          icon: Icons.error_outline,
          message: 'No se pudo cargar tu seguimiento.',
        ),
        data: (matches) {
          final favorites = favoritesAsync.value ?? const {};

          if (favorites.isEmpty) {
            return const StateMessage(
              icon: Icons.bookmark_border,
              message: 'Marca equipos favoritos en la pestaña Equipos para verlos aquí.',
            );
          }

          final favoriteMatches = matches
              .where((m) => favorites.contains(m.teamA.id) || favorites.contains(m.teamB.id))
              .toList();
          final byDay = groupMatchesByDay(favoriteMatches);
          final dayMatches = byDay[_selectedDay] ?? const <MatchModel>[];

          return Column(
            children: [
              MonthCalendar(
                month: _month,
                selectedDay: _selectedDay,
                daysWithMatches: byDay.keys.toSet(),
                onSelectDay: (day) => setState(() => _selectedDay = day),
                onPrevMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: dayMatches.isEmpty
                      ? const StateMessage(
                          key: ValueKey('empty'),
                          icon: Icons.event_busy,
                          message: 'No tienes partidos de tus favoritos ese día.',
                        )
                      : ListView.builder(
                          key: ValueKey(_selectedDay),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: dayMatches.length,
                          itemBuilder: (context, index) => MatchCard(
                            match: dayMatches[index],
                            favoriteTeamIds: favorites,
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
}
