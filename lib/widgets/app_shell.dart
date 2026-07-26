import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/nav_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/update_provider.dart';
import '../services/update_checker.dart';
import '../theme/app_theme.dart';

const _destinations = [
  (icon: Icons.calendar_month, label: 'Calendario'),
  (icon: Icons.calendar_view_month, label: 'Seguimiento'),
  (icon: Icons.groups, label: 'Equipos'),
  (icon: Icons.emoji_events, label: 'Torneos'),
  (icon: Icons.settings, label: 'Ajustes'),
  (icon: Icons.article, label: 'Noticias'),
];

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  Future<void> _handleUpdateTap(BuildContext context, WidgetRef ref, UpdateInfo update) async {
    if (!Platform.isAndroid) {
      launchUrl(Uri.parse(update.downloadUrlWindows), mode: LaunchMode.externalApplication);
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    ref.read(apkDownloadingProvider.notifier).state = true;
    try {
      await ref.read(apkUpdaterProvider).downloadAndInstall(update.downloadUrlAndroid);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo instalar la actualización: $e')),
        );
      }
    } finally {
      ref.read(apkDownloadingProvider.notifier).state = false;
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, UpdateInfo update) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Actualización disponible', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Hay una nueva versión disponible (v${update.latestVersion}).',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final downloading = ref.watch(apkDownloadingProvider);
              return TextButton(
                onPressed: downloading
                    ? null
                    : () {
                        ref.read(updateBannerDismissedProvider.notifier).state = true;
                        Navigator.of(dialogContext).pop();
                      },
                child: const Text('Ahora no'),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final downloading = ref.watch(apkDownloadingProvider);
              return FilledButton(
                onPressed: downloading ? null : () => _handleUpdateTap(dialogContext, ref, update),
                child: downloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(Platform.isAndroid ? 'Actualizar' : 'Descargar'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(matchReminderCheckerProvider);
    final scaffoldKey = ref.watch(scaffoldKeyProvider);

    ref.listen<AsyncValue<UpdateInfo?>>(updateCheckProvider, (previous, next) {
      final update = next.value;
      if (update != null && !ref.read(updateBannerDismissedProvider)) {
        _showUpdateDialog(context, ref, update);
      }
    });

    void selectBranch(int index) {
      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
    }

    if (Platform.isWindows) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            SizedBox(
              width: 220,
              child: ColoredBox(
                color: AppColors.surface,
                child: _NavList(currentIndex: navigationShell.currentIndex, onSelect: selectBranch),
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.divider),
            Expanded(child: SafeArea(child: navigationShell)),
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
      body: SafeArea(child: navigationShell),
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
            'Pulse',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < _destinations.length; i++)
          _NavItem(
            icon: _destinations[i].icon,
            label: _destinations[i].label,
            selected: i == currentIndex,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent.withValues(alpha: 0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? AppColors.accentOnDark : AppColors.textSecondary),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
