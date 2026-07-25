import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'providers/group_provider.dart';
import 'router.dart';
import 'services/auth_service.dart';
import 'services/group_repository.dart';
import 'services/group_store.dart';
import 'services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService().ensureSignedIn();

  final groupCode = await GroupStore().loadCode();
  if (groupCode != null) {
    await PushService().registerToken(groupCode, GroupRepository());
  }

  final router = buildAppRouter(initialLocation: groupCode == null ? '/link' : '/calendar');

  runApp(
    ProviderScope(
      overrides: [groupCodeProvider.overrideWith((ref) => groupCode)],
      child: DotaScheduleApp(router: router),
    ),
  );
}

class DotaScheduleApp extends StatelessWidget {
  const DotaScheduleApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dota 2 Schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB22222)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
