import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/reminder_provider.dart';
import '../providers/update_provider.dart';
import '../theme/app_theme.dart';

const _destinations = [
  (icon: Icons.calendar_month, label: 'Calendario'),
  (icon: Icons.groups, label: 'Equipos'),
  (icon: Icons.settings, label: 'Ajustes'),
];

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

    final banner = update != null && !dismissed
        ? MaterialBanner(
            backgroundColor: AppColors.surface,
            content: Text(
              'Hay una actualización disponible (v${update.latestVersion})',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
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
          )
        : null;

    if (Platform.isWindows) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ?banner,
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    backgroundColor: AppColors.surface,
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: (index) => navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    ),
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)),
                    ],
                  ),
                  const VerticalDivider(width: 1, color: AppColors.divider),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ?banner,
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final d in _destinations) NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}
