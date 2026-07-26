import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/reminder_provider.dart';
import '../providers/update_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(matchReminderCheckerProvider);
    final updateAsync = ref.watch(updateCheckProvider);
    final update = updateAsync.value;
    final dismissed = ref.watch(updateBannerDismissedProvider);
    final downloading = ref.watch(apkDownloadingProvider);

    Future<void> handleUpdateTap() async {
      if (!Platform.isAndroid) {
        launchUrl(Uri.parse(update!.downloadUrlWindows), mode: LaunchMode.externalApplication);
        return;
      }
      ref.read(apkDownloadingProvider.notifier).state = true;
      try {
        await ref.read(apkUpdaterProvider).downloadAndInstall(update!.downloadUrlAndroid);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo instalar la actualización: $e')),
          );
        }
      } finally {
        ref.read(apkDownloadingProvider.notifier).state = false;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          if (update != null && !dismissed)
            MaterialBanner(
              content: Text('Hay una actualización disponible (v${update.latestVersion})'),
              actions: [
                TextButton(
                  onPressed: downloading ? null : () => ref.read(updateBannerDismissedProvider.notifier).state = true,
                  child: const Text('Ahora no'),
                ),
                FilledButton(
                  onPressed: downloading ? null : handleUpdateTap,
                  child: downloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(Platform.isAndroid ? 'Actualizar' : 'Descargar'),
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
