import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

// ----------------- Application Code Imports -----------------
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/player/presentation/animated_instruction.dart';
import 'package:zenigo/src/features/player/presentation/routine_player_screen.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';
// -----------------------------------------------------------

// A mock of your RoutineRepository.
class MockRoutineRepository extends Mock implements RoutineRepository {}
class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const testRoutineId = 'routine-1';
  final testRoutine = Routine(
    id: testRoutineId,
    title: 'Morning Mindfulness',
    description: 'A test routine for mindfulness.',
    category: RoutineCategory.values.first,
    blocks: [
      Block(
          id: 'block-1',
          routineId: testRoutineId,
          instruction: 'Breathe In',
          duration: 4,
          order: 1),
      Block(
          id: 'block-2',
          routineId: testRoutineId,
          instruction: 'Hold',
          duration: 7,
          order: 2),
      Block(
          id: 'block-3',
          routineId: testRoutineId,
          instruction: 'Breathe Out',
          duration: 8,
          order: 3),
    ],
  );

  late MockRoutineRepository mockRoutineRepository;
  late MockProgressRepository mockProgressRepository;

  setUpAll(() async {
    // Mock SharedPreferences
    // ignore: deprecated_member_use
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
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
    });

    try {
      await Supabase.initialize(
        url: 'http://localhost:54321', // Dummy URL
        anonKey: 'dummy_anon_key', // Dummy key
      );
    } catch (e) {
      if (!e.toString().contains('is already initialized')) {
        rethrow;
      }
    }
    registerFallbackValue(const Routine(
      id: 'fallbackId',
      title: 'Fallback Title',
      description: 'Fallback Description',
      category: RoutineCategory.all,
      blocks: [],
    ));
    registerFallbackValue(UserSession(
        routineId: 'fallback',
        routineTitle: 'fallback',
        completedAt: DateTime(2000),
        durationInSeconds: 0));
  });

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
    mockProgressRepository = MockProgressRepository();

    when(() => mockProgressRepository.addSession(any())).thenAnswer((_) async {});
    when(() => mockProgressRepository.watchUserStats())
        .thenAnswer((_) => Stream.value(const UserStats(dailyStreak: 0, totalMinutes: 0)));
    when(() => mockProgressRepository.getUserStats())
        .thenAnswer((_) async => const UserStats(dailyStreak: 0, totalMinutes: 0));
    when(() => mockProgressRepository.getSessionHistory())
        .thenAnswer((_) async => <UserSession>[]);
    when(() => mockRoutineRepository.getAllRoutines())
        .thenAnswer((_) async => <Routine>[]);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required Widget home,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
          progressRepositoryProvider.overrideWithValue(mockProgressRepository),
        ],
        child: MaterialApp(
          home: home,
        ),
      ),
    );
  }

  testWidgets(
      'initially shows loading indicator then displays routine on successful load',
      (tester) async {
    when(() => mockRoutineRepository.getRoutineById(testRoutineId))
        .thenAnswer((_) async => testRoutine);

    await pumpScreen(
      tester,
      home: const RoutinePlayerScreen(routineId: testRoutineId),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();

    expect(find.byType(RoutinePlayerScreen), findsOneWidget);
    expect(find.text('Morning Mindfulness'), findsOneWidget);
    expect(find.byType(AnimatedInstruction), findsOneWidget);
    expect(find.byIcon(AppIcons.pause), findsOneWidget);
  });


  testWidgets('tapping close button pops the navigation stack', (tester) async {
    // Arrange: Create a routine with a very long block to prevent it from finishing
    final longRoutine = testRoutine.copyWith(
      blocks: [
        const Block(
            id: 'long-block',
            routineId: testRoutineId,
            instruction: 'Just wait',
            duration: 9999,
            order: 1),
      ],
    );
    when(() => mockRoutineRepository.getRoutineById(testRoutineId))
        .thenAnswer((_) async => longRoutine);

    await pumpScreen(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              child: const Text('Go to Player'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const RoutinePlayerScreen(routineId: testRoutineId),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Act: Navigate to the player screen
    await tester.tap(find.text('Go to Player'));
    await tester.pump(); // Start the navigation
    await tester.pump(); // Build the RoutinePlayerScreen frame

    // Assert: The screen is present and "stuck" on its long block
    expect(find.byType(RoutinePlayerScreen), findsOneWidget);

    // Act: Tap the close button
    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle(); // Let the pop animation finish

    // Assert: The screen is gone
    expect(find.byType(RoutinePlayerScreen), findsNothing);
  });
}