import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';
import 'package:zenigo/src/features/progress/presentation/progress_screen.dart';

import 'progress_screen_test.mocks.dart';

@GenerateMocks([ProgressRepository])
void main() {
  late MockProgressRepository mockProgressRepository;

  // Default success data
  final testStats = const UserStats(dailyStreak: 5, totalMinutes: 20);
  final testHistory = [
    UserSession(
      routineId: '1',
      routineTitle: 'Morning Stretch',
      completedAt: DateTime.now(),
      durationInSeconds: 120,
    ),
  ];

  setUp(() {
    mockProgressRepository = MockProgressRepository();
    // Default success case
    when(mockProgressRepository.getUserStats()).thenAnswer((_) async => testStats);
    when(mockProgressRepository.getSessionHistory()).thenAnswer((_) async => testHistory);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(mockProgressRepository),
        ],
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
  }

  group('ProgressScreen', () {
    testWidgets('shows loading indicator then displays stats and history', (tester) async {
      await pumpScreen(tester);

      // Initial loading state from the FutureProviders
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Settle the futures
      await tester.pumpAndSettle();

      // Verify UI displays the data
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('Morning Stretch'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('displays empty state message when there is no data', (tester) async {
      // Override default mocks for the empty case
      when(mockProgressRepository.getUserStats())
          .thenAnswer((_) async => const UserStats(dailyStreak: 0, totalMinutes: 0));
      when(mockProgressRepository.getSessionHistory()).thenAnswer((_) async => []);

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('No recent activity.'), findsOneWidget);
      // Ensure stats show '0' and not the default mock data
      expect(find.text('5'), findsNothing);
      expect(find.text('0'), findsNWidgets(2)); // For both streak and minutes
    });

    testWidgets('displays error message when stats provider fails', (tester) async {
      // Override mock to throw an error for one of the providers
      when(mockProgressRepository.getUserStats()).thenThrow(Exception('Failed to load stats'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing); // History shouldn't show either
    });

    testWidgets('displays error message when history provider fails', (tester) async {
      // Override mock to throw an error for the other provider
      when(mockProgressRepository.getSessionHistory()).thenThrow(Exception('Failed to load history'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error'), findsOneWidget);
      // Stats might still show if that provider succeeded, but the list will fail.
      expect(find.byType(ListTile), findsNothing);
    });
  });
}