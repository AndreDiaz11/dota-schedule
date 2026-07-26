import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/match_model.dart';
import 'models/team.dart';
import 'screens/calendar_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/link_screen.dart';
import 'screens/match_detail_screen.dart';
import 'screens/news_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/team_profile_screen.dart';
import 'screens/team_selector_screen.dart';
import 'screens/tournaments_screen.dart';
import 'screens/watchlist_screen.dart';
import 'widgets/app_shell.dart';

Page<void> _detailTransitionPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter buildAppRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/link', builder: (context, state) => const LinkScreen()),
      GoRoute(
        path: '/match',
        pageBuilder: (context, state) => _detailTransitionPage(MatchDetailScreen(match: state.extra as MatchModel), state),
      ),
      GoRoute(
        path: '/team',
        pageBuilder: (context, state) => _detailTransitionPage(TeamProfileScreen(team: state.extra as Team), state),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/watchlist', builder: (context, state) => const WatchlistScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/teams', builder: (context, state) => const TeamSelectorScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tournaments', builder: (context, state) => const TournamentsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
          ]),
        ],
      ),
    ],
  );
}
