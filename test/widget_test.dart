import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/main.dart';

void main() {
  // This setup is run once before all tests in this file
  setUpAll(() async {
    // This is required to mock platform channels.
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the shared_preferences platform channel before initializing Supabase
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{}; // Return an empty map for the test
        }
        return null;
      },
    );

    // Initialize Supabase with dummy data
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'dummy_key',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
      ),
    );
  });

  // Clear the mock handlers after the tests
  tearDownAll(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      null,
    );
  });

  testWidgets('MyApp builds and shows AuthScreen initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle(); // Let the router do its initial redirect

    // Verify that the AuthScreen is shown because no user is logged in.
    expect(find.text('Find your flow.'), findsOneWidget);
  });
}
