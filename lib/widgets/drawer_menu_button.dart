import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nav_provider.dart';

class DrawerMenuButton extends ConsumerWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Platform.isWindows) return const SizedBox.shrink();
    final scaffoldKey = ref.watch(scaffoldKeyProvider);
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => scaffoldKey.currentState?.openDrawer(),
    );
  }
}
