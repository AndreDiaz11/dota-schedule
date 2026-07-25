import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/auth_service.dart';
import '../services/group_repository.dart';
import '../services/group_store.dart';

final groupCodeProvider = StateProvider<String?>((ref) => null);

final groupRepositoryProvider = Provider<GroupRepository>((ref) => GroupRepository());

final groupStoreProvider = Provider<GroupStore>((ref) => GroupStore());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
