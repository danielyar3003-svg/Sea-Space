import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Authentication boundary. The app never sees or stores passwords beyond
/// passing them to Supabase Auth over HTTPS.
abstract class AuthService extends ChangeNotifier {
  bool get isSignedIn;
  String? get email;

  /// Current access token, refreshed by the SDK when it is close to expiry.
  Future<String?> accessToken();

  Future<void> signIn({required String email, required String password});

  /// Returns true when the account needs e-mail confirmation before signing in.
  Future<bool> signUp({required String email, required String password});

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.unreachable = false});
  final String message;

  /// True when the auth service could not be reached (the UI shows a translated text).
  final bool unreachable;
  @override
  String toString() => message;
}

class SupabaseAuthService extends AuthService {
  SupabaseAuthService(this._client) {
    _sub = _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final sb.SupabaseClient _client;
  late final StreamSubscription<sb.AuthState> _sub;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  String? get email => _client.auth.currentUser?.email;

  @override
  Future<String?> accessToken() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    if (session.isExpired) {
      try {
        final refreshed = await _client.auth.refreshSession();
        return refreshed.session?.accessToken;
      } on sb.AuthException {
        return null;
      }
    }
    return session.accessToken;
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _client.auth.signInWithPassword(email: email, password: password));

  @override
  Future<bool> signUp({required String email, required String password}) async {
    final res = await _guard(() => _client.auth.signUp(email: email, password: password));
    return res.session == null;
  }

  @override
  Future<void> sendPasswordReset(String email) => _guard(() => _client.auth.resetPasswordForEmail(email));

  @override
  Future<void> signOut() => _guard(() => _client.auth.signOut());

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on sb.AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Could not reach the authentication service.', unreachable: true);
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
