import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRepository {
  final _firestore = FirebaseFirestore.instance;

  static const defaultLeadMinutes = 30;

  String generateCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  DocumentReference<Map<String, dynamic>> _doc(String code) =>
      _firestore.collection('groups').doc(code);

  Future<void> createGroup(String code) {
    return _doc(code).set({
      'favoriteTeamIds': <String>[],
      'notificationLeadMinutes': defaultLeadMinutes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> groupExists(String code) async {
    final snapshot = await _doc(code).get();
    return snapshot.exists;
  }

  Stream<Map<String, dynamic>> watchGroup(String code) {
    return _doc(code).snapshots().map((snapshot) => snapshot.data() ?? {});
  }

  Future<void> addFavorite(String code, String teamId) {
    return _doc(code).update({
      'favoriteTeamIds': FieldValue.arrayUnion([teamId]),
    });
  }

  Future<void> removeFavorite(String code, String teamId) {
    return _doc(code).update({
      'favoriteTeamIds': FieldValue.arrayRemove([teamId]),
    });
  }

  Future<void> updateLeadMinutes(String code, int minutes) {
    return _doc(code).update({'notificationLeadMinutes': minutes});
  }

  Future<void> addFcmToken(String code, String token) {
    return _doc(code).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
