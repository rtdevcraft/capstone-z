import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/auth/auth_repository.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';

import 'dashboard_screen_test.mocks.dart';

// The screen depends on data from these three repositories.
@GenerateMocks([RoutineRepository, ProgressRepository, AuthRepository])
void main() {
  late MockRoutineRepository mockRoutineRepository;
  late MockProgressRepository mockProgressRepository;
  late MockAuthRepository mockAuthRepository;

  // Default success data
  final testRoutines = [
    Routine(
      id: 'desk-reset',
      title: 'Desk Worker\'s Reset',
      description: '',
      category: RoutineCategory.targetedRelief,
    ),
  ];
  final testStats = const UserStats(dailyStreak: 3, totalMinutes: 2);

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
    mockProgressRepository = MockProgressRepository();
    mockAuthRepository = MockAuthRepository();

    // Default success case for all mocks
    when(mockRoutineRepository.getAllRoutines()).thenAnswer((_) async => testRoutines);
    when(mockProgressRepository.watchUserStats()).thenAnswer((_) => Stream.value(testStats));
    when(mockAuthRepository.signOut()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
          progressRepositoryProvider.overrideWithValue(mockProgressRepository),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
  }

  group('DashboardScreen', () {
    testWidgets('shows loading indicator then displays dashboard data', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Desk Worker\'s Reset'), findsOneWidget);
    });

    testWidgets('shows error message when fetching stats fails', (tester) async {
      when(mockProgressRepository.watchUserStats()).thenAnswer((_) => Stream.error(Exception('Failed to load stats')));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('shows error message when fetching routines fails', (tester) async {
      when(mockRoutineRepository.getAllRoutines()).thenThrow(Exception('Failed to load routines'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('calls signOut when logout button is tapped', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(AppIcons.logout));

      verify(mockAuthRepository.signOut()).called(1);
    });
  });
}