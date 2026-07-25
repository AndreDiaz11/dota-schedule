import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/match_repository.dart';
import '../services/mock_match_repository.dart';
import '../services/pandascore_match_repository.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final apiKey = dotenv.env['PANDASCORE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    return MockMatchRepository();
  }
  return PandaScoreMatchRepository(apiKey);
});
