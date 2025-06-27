import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/main.dart' as app;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Zenigo E2E Test', () {
    late SupabaseClient adminClient;

    setUpAll(() async {
      await dotenv.load(fileName: ".env.test");

      final url = dotenv.env['SUPABASE_URL'];
      final serviceKey = dotenv.env['SUPABASE_SERVICE_KEY'];

      if (url == null || serviceKey == null) {
        throw Exception('Supabase credentials not found in .env.test');
      }
      adminClient = SupabaseClient(url, serviceKey);
    });

    tearDownAll(() async {
      await adminClient.dispose();
    });

    testWidgets('New user sign up flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byIcon(Icons.logout).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      
      expect(find.byKey(const Key('signin_button')), findsOneWidget, reason: "Should be on AuthScreen to start the test");

      final email = 'new-user-${DateTime.now().millisecondsSinceEpoch}@example.com';
      const password = 'password123';

      final emailField = find.byKey(const Key('auth_email_field'));
      final passwordField = find.byKey(const Key('auth_password_field'));
      final signUpButton = find.byKey(const Key('signup_button'));

      debugPrint('Email: $email');
      debugPrint('Password: $password');
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
      await tester.pumpAndSettle();
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      debugPrint('Sign up button tapped');

      expect(find.text('Your Dashboard'), findsOneWidget, reason: "Should navigate to Dashboard after sign-up");

      final testUser = Supabase.instance.client.auth.currentUser;
      expect(testUser, isNotNull);

      try {
        await adminClient.auth.admin.deleteUser(testUser!.id);
      } catch (e) {
        debugPrint('Error deleting user: $e');
      }
    });
  });
}