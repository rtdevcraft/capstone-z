import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/core/auth/auth_failures.dart';
import 'package:zenigo/src/core/auth/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient])
void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late AuthRepository authRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    authRepository = AuthRepository(mockSupabaseClient);
  });

  group('AuthRepository', () {
    group('signInWithEmail', () {
      test('should complete successfully when signInWithPassword succeeds', () async {
        when(mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password',
        )).thenAnswer((_) async => AuthResponse());

        await expectLater(
          authRepository.signInWithEmail('test@example.com', 'password'),
          completes,
        );
      });

      test('should throw SignInFailure when signInWithPassword throws AuthException', () async {
        when(mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password',
        )).thenThrow(AuthException('Auth error'));

        await expectLater(
          authRepository.signInWithEmail('test@example.com', 'password'),
          throwsA(isA<SignInFailure>()),
        );
      });

      test('should throw SignInFailure for other exceptions', () async {
        when(mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password',
        )).thenThrow(Exception('Some other error'));

        await expectLater(
          authRepository.signInWithEmail('test@example.com', 'password'),
          throwsA(isA<SignInFailure>()),
        );
      });
    });

    group('signUpWithEmail', () {
      test('should complete successfully when signUp succeeds', () async {
        when(mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password',
        )).thenAnswer((_) async => AuthResponse());

        await expectLater(
          authRepository.signUpWithEmail('test@example.com', 'password'),
          completes,
        );
      });

      test('should throw SignUpFailure when signUp throws AuthException', () async {
        when(mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password',
        )).thenThrow(AuthException('Auth error'));

        await expectLater(
          authRepository.signUpWithEmail('test@example.com', 'password'),
          throwsA(isA<SignUpFailure>()),
        );
      });

      test('should throw SignUpFailure for other exceptions', () async {
        when(mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password',
        )).thenThrow(Exception('Some other error'));

        await expectLater(
          authRepository.signUpWithEmail('test@example.com', 'password'),
          throwsA(isA<SignUpFailure>()),
        );
      });
    });

    group('signOut', () {
      test('should complete successfully when signOut succeeds', () async {
        when(mockGoTrueClient.signOut(scope: anyNamed('scope')))
            .thenAnswer((_) async {});

        await expectLater(authRepository.signOut(), completes);
      });

      test('should throw Exception when signOut fails', () async {
        when(mockGoTrueClient.signOut(scope: anyNamed('scope')))
            .thenThrow(Exception('Sign out failed'));

        await expectLater(
          authRepository.signOut(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // Test for the provider
    group('authRepositoryProvider', () {
      const MethodChannel channel =
          MethodChannel('plugins.flutter.io/shared_preferences');
      setUpAll(() async {
        TestWidgetsFlutterBinding.ensureInitialized();
        // Mock SharedPreferences
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          channel,
          (MethodCall methodCall) async {
            if (methodCall.method == 'getAll') {
              return <String, dynamic>{}; // Empty map for testing
            }
            if (methodCall.method == 'setString') {
              return true;
            }
            if (methodCall.method == 'remove') {
              return true;
            }
            return null;
          },
        );

        // Initialize Supabase with dummy values for testing
        await Supabase.initialize(
          url: 'http://localhost:54321', // Dummy URL
          anonKey: 'dummy_anon_key', // Dummy key
        );
      });

      tearDownAll(() async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        // Dispose of Supabase instance if necessary, though usually not explicitly needed for tests
        // as a new instance is created if initialize is called again.
        // However, if there's a specific dispose method in your Supabase setup, call it here.
      });

      test('provides an instance of AuthRepository', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Mock Supabase.instance.client
        // This is a bit tricky as Supabase.instance is static.
        // For a real app, you might inject SupabaseClient directly or use a wrapper.
        // For this test, we'll assume the global instance is available and works,
        // or this part would need a more complex setup (e.g., using a testing-specific Supabase initialization).
        // However, the provider itself simply news up AuthRepository with the client.
        // The core logic of AuthRepository is already tested above with mocks.

        // We can't easily mock Supabase.instance.client without more complex setup.
        // So, we'll focus on the fact that the provider *should* return an AuthRepository.
        // A more robust test would involve overriding the Supabase.instance for testing.
        expect(container.read(authRepositoryProvider), isA<AuthRepository>());
      });
    });
  });
}