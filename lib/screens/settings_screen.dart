import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/group_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _options = {
    15: '15 minutos antes',
    30: '30 minutos antes',
    60: '1 hora antes',
    180: '3 horas antes',
    1440: '1 día antes',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(notificationLeadProvider);
    final notifier = ref.read(notificationLeadProvider.notifier);
    final groupCode = ref.watch(groupCodeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: leadAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (currentMinutes) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (groupCode != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: Text('Tu código de vinculación: $groupCode'),
                  subtitle: const Text('Úsalo para sincronizar otro dispositivo'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: groupCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado')),
                      );
                    },
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Avisarme con anticipación'),
            ),
            RadioGroup<int>(
              groupValue: currentMinutes,
              onChanged: (v) {
                if (v != null) notifier.setLeadMinutes(v);
              },
              child: Column(
                children: [
                  for (final entry in _options.entries)
                    RadioListTile<int>(
                      title: Text(entry.value),
                      value: entry.key,
                    ),
                ],
              ),
            ),
            const Divider(height: 32),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('En la PC, las notificaciones solo aparecen mientras el programa está abierto.'),
            ),
          ],
        ),
      ),
    );
  }
}
