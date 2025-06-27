import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_failures.dart';

/// A repository for handling all authentication-related operations
/// with the Supabase backend.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Signs in the user with the given email and password.
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw SignInFailure(e.message);
    } catch (e) {
      throw const SignInFailure();
    }
  }

  /// Signs up a new user with the given email and password.
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw SignUpFailure(e.message);
    } catch (e) {
      throw const SignUpFailure();
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      debugPrint('--> Attempting to sign out...');
      await _client.auth.signOut(scope: SignOutScope.global);
      debugPrint('--> Sign out call completed.');
    } catch (e) {
      debugPrint('--> Sign out failed: $e');
      throw Exception('Failed to sign out.');
    }
  }
}

/// Provides an instance of the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = Supabase.instance.client;
  return AuthRepository(client);
});