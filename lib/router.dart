import 'package:go_router/go_router.dart';

import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/team_selector_screen.dart';
import 'widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/calendar',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/teams', builder: (context, state) => const TeamSelectorScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);
