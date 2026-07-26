import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/nav_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/update_provider.dart';
import '../theme/app_theme.dart';

const _destinations = [
  (icon: Icons.calendar_month, label: 'Calendario'),
  (icon: Icons.groups, label: 'Equipos'),
  (icon: Icons.settings, label: 'Ajustes'),
  (icon: Icons.article, label: 'Noticias'),
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
    final scaffoldKey = ref.watch(scaffoldKeyProvider);

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

    void selectBranch(int index) {
      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
    }

    if (Platform.isWindows) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ?banner,
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: _NavList(currentIndex: navigationShell.currentIndex, onSelect: selectBranch),
                    ),
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
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: _NavList(
            currentIndex: navigationShell.currentIndex,
            onSelect: (index) {
              Navigator.of(context).pop();
              selectBranch(index);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          ?banner,
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _NavList extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _NavList({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Dota 2 Schedule',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < _destinations.length; i++)
          ListTile(
            selected: i == currentIndex,
            selectedTileColor: AppColors.accent.withValues(alpha: 0.18),
            leading: Icon(
              _destinations[i].icon,
              color: i == currentIndex ? AppColors.accentOnDark : AppColors.textSecondary,
            ),
            title: Text(
              _destinations[i].label,
              style: TextStyle(color: i == currentIndex ? AppColors.textPrimary : AppColors.textSecondary),
            ),
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}
