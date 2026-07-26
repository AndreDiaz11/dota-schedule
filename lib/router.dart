import 'package:go_router/go_router.dart';

import 'screens/calendar_screen.dart';
import 'screens/link_screen.dart';
import 'screens/news_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/team_selector_screen.dart';
import 'widgets/app_shell.dart';

GoRouter buildAppRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/link', builder: (context, state) => const LinkScreen()),
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
          StatefulShellBranch(routes: [
            GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
          ]),
        ],
      ),
    ],
  );
}
