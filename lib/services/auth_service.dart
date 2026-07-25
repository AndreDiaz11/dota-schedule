import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<User> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    final current = auth.currentUser;
    if (current != null) return current;
    final credential = await auth.signInAnonymously();
    return credential.user!;
  }
}
