import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the current authentication state of the user.
///
/// This is the most critical provider for authentication. It exposes the
/// Supabase AuthState stream, which automatically notifies listeners
/// whenever the user signs in, signs out, or the session is refreshed.
/// This allows the app's UI to reactively update based on the auth status.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});