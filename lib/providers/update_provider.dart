import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/apk_updater.dart';
import '../services/update_checker.dart';

final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) {
  return UpdateChecker().checkForUpdate();
});

final updateBannerDismissedProvider = StateProvider<bool>((ref) => false);

final apkUpdaterProvider = Provider<ApkUpdater>((ref) => ApkUpdater());

final apkDownloadingProvider = StateProvider<bool>((ref) => false);
