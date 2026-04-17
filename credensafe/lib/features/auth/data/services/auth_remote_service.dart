import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';

class AuthRemoteService {
  AuthRemoteService(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  User? currentUser() => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: emailRedirectTo ?? EnvConfig.authRedirectUrl,
    );
  }

  Future<void> resetPasswordForEmail({
    required String email,
    String? redirectTo,
  }) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? EnvConfig.authRedirectUrl,
    );
  }

  Future<UserResponse> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
