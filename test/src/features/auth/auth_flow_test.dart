import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/auth/auth_repository.dart';
import 'package:zenigo/src/features/auth/presentation/auth_screen.dart';

import 'auth_flow_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // Default success case for auth calls
    when(mockAuthRepository.signInWithEmail(any, any)).thenAnswer((_) async {});
    when(mockAuthRepository.signUpWithEmail(any, any)).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(home: AuthScreen()),
      ),
    );
  }

  group('AuthScreen', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Find your flow.'), findsOneWidget);
      expect(find.byKey(const Key('auth_email_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_password_field')), findsOneWidget);
      expect(find.byKey(const Key('signin_button')), findsOneWidget);
      expect(find.byKey(const Key('signup_button')), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields on Sign In', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('calls signInWithEmail and shows loading indicator', (tester) async {
      final completer = Completer<void>();
      when(mockAuthRepository.signInWithEmail(any, any)).thenAnswer((_) => completer.future);

      await pumpScreen(tester);

      await tester.enterText(find.byKey(const Key('auth_email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('auth_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pump(); // Start loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(mockAuthRepository.signInWithEmail('test@example.com', 'password123')).called(1);

      completer.complete();
      await tester.pumpAndSettle(); // Finish loading

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls signUpWithEmail when Sign Up is tapped', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byKey(const Key('auth_email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('auth_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('signup_button')));
      await tester.pump();

      verify(mockAuthRepository.signUpWithEmail('test@example.com', 'password123')).called(1);
    });

    testWidgets('shows SnackBar when signInWithEmail fails', (tester) async {
      final exception = Exception('Invalid credentials');
      when(mockAuthRepository.signInWithEmail(any, any)).thenThrow(exception);

      await pumpScreen(tester);

      await tester.enterText(find.byKey(const Key('auth_email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('auth_password_field')), 'password123');
      await tester.tap(find.byKey(const Key('signin_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(exception.toString()), findsOneWidget);
    });
  });
}