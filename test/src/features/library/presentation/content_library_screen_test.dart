import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/library/presentation/content_library_screen.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';

import 'content_library_screen_test.mocks.dart';

@GenerateMocks([RoutineRepository])
void main() {
  // --- Test Data ---
  final testRoutines = [
    Routine(
      id: '1',
      title: 'Morning Stretch',
      description: 'A gentle routine to start your day.',
      category: RoutineCategory.mindfulMorning,
      blocks: const [], // Added to satisfy constructor
    ),
    Routine(
      id: '2',
      title: 'Deep Sleep Prep',
      description: 'Relax your body for a good night\'s sleep.',
      category: RoutineCategory.eveningWindDown,
      blocks: const [],
    ),
    Routine(
      id: '3',
      title: 'Focus Booster',
      description: 'A quick session to clear your mind and focus.',
      category: RoutineCategory.focusClarity,
      blocks: const [],
    ),
    Routine(
      id: '4',
      title: 'Mindful Morning Meditation',
      description: 'A short meditation to cultivate presence.',
      category: RoutineCategory.mindfulMorning,
      blocks: const [],
    ),
  ];

  late MockRoutineRepository mockRoutineRepository;

  // Helper to create a ProviderContainer with the mocked repository
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
    // Default success case
    when(mockRoutineRepository.getAllRoutines()).thenAnswer((_) async => testRoutines);
  });

  group('filteredRoutinesProvider', () {
    test('returns all routines when no filters are applied', () async {
      final container = createContainer();
      await container.read(allRoutinesProvider.future);
      
      final result = container.read(filteredRoutinesProvider);
      
      expect(result.length, 4);
    });

    test('filters by category correctly', () async {
      final container = createContainer();
      await container.read(allRoutinesProvider.future);

      container.read(categoryFilterProvider.notifier).state = RoutineCategory.mindfulMorning;

      final result = container.read(filteredRoutinesProvider);
      expect(result.length, 2);
      expect(result.every((r) => r.category == RoutineCategory.mindfulMorning), isTrue);
    });

    test('filters by search query in title (case-insensitive)', () async {
      final container = createContainer();
      await container.read(allRoutinesProvider.future);

      container.read(searchQueryProvider.notifier).state = 'morning';

      final result = container.read(filteredRoutinesProvider);
      expect(result.length, 2);
      expect(result.map((r) => r.id), containsAll(['1', '4']));
    });
    
    // ... other provider tests remain the same ...
  });

  group('ContentLibraryScreen Widget Tests', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
          ],
          child: const MaterialApp(home: ContentLibraryScreen()),
        ),
      );
    }

    testWidgets('renders loading indicator and then grid of routines', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Morning Stretch'), findsOneWidget);
      expect(find.text('Deep Sleep Prep'), findsOneWidget);
    });

    testWidgets('filters list when user types in search bar', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'sleep');
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Deep Sleep Prep'), findsOneWidget);
      expect(find.text('Morning Stretch'), findsNothing);
    });

    testWidgets('shows error message when fetching routines fails', (tester) async {
      when(mockRoutineRepository.getAllRoutines()).thenThrow(Exception('Failed to load'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('clear button clears search and shows all routines', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'sleep');
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Morning Stretch'), findsOneWidget);
      expect(find.text('Deep Sleep Prep'), findsOneWidget);
      expect(find.text('sleep'), findsNothing);
    });

    testWidgets('displays correct number of columns based on screen width', (tester) async {
      // Narrow screen
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      GridView gridView = tester.widget(find.byType(GridView));
      expect((gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 2);

      // Wide screen
      tester.view.physicalSize = const Size(1200, 800);
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      gridView = tester.widget(find.byType(GridView));
      expect((gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 4);

      // Reset size
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
    });
  });
}