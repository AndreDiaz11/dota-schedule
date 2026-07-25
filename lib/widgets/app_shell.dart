import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/update_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateAsync = ref.watch(updateCheckProvider);
    final update = updateAsync.value;
    final dismissed = ref.watch(updateBannerDismissedProvider);

    return Scaffold(
      body: Column(
        children: [
          if (update != null && !dismissed)
            MaterialBanner(
              content: Text('Hay una actualización disponible (v${update.latestVersion})'),
              actions: [
                TextButton(
                  onPressed: () => ref.read(updateBannerDismissedProvider.notifier).state = true,
                  child: const Text('Ahora no'),
                ),
                FilledButton(
                  onPressed: () {
                    final url = Platform.isWindows ? update.downloadUrlWindows : update.downloadUrlAndroid;
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                  child: const Text('Descargar'),
                ),
              ],
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Equipos'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
