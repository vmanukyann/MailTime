import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  bool get isSignedIn => _client.auth.currentSession != null;

  User? get currentUser => _client.auth.currentUser;

  String? get currentUserEmail => currentUser?.email;

  String get currentUserId => currentUser?.id ?? '';

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      await _client.from('users').upsert({
        'id': user.id,
        'email': user.email,
      });
    }

    return response;
  }

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> updateEmail(String email) async {
    await _client.auth.updateUser(UserAttributes(email: email));
    await _client.from('users').update({'email': email}).eq('id', currentUserId);
  }

  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> deleteAccount() async {
    // Requires a secure Edge Function with service role key.
    await _client.functions.invoke('delete-account');
  }
}
