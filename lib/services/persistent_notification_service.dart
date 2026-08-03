import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/match_model.dart';

class PersistentNotificationService {
  static const _channel = MethodChannel('pulse/persistent_notification');

  Future<void> sync(List<MatchModel> favoriteMatches, {required int leadMinutes}) async {
    final payload = favoriteMatches
        .map((m) => {
              'id': m.id,
              'teamA': m.teamA.name,
              'teamB': m.teamB.name,
              'tournament': m.tournament.name,
              'startTimeMs': m.startTimeUtc.millisecondsSinceEpoch,
              'isLive': m.isLive,
            })
        .toList();

    await _channel.invokeMethod('sync', {
      'matchesJson': jsonEncode(payload),
      'leadMinutes': leadMinutes,
    });
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}
