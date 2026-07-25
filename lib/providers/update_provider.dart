import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/update_checker.dart';

final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) {
  return UpdateChecker().checkForUpdate();
});

final updateBannerDismissedProvider = StateProvider<bool>((ref) => false);
