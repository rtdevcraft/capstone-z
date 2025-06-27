import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/features/progress/data/progress_api.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';

import 'progress_repository_test.mocks.dart';

@GenerateMocks([ProgressApi, Routine, Block, SupabaseClient, GoTrueClient, User])
void main() {
  late ProgressRepository progressRepository;
  late MockProgressApi mockProgressApi;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;

  setUp(() {
    mockProgressApi = MockProgressApi();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();

    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(mockUser.id).thenReturn('test-user-id');

    progressRepository =
        ProgressRepository(mockProgressApi, client: mockSupabaseClient);
  });

  group('ProgressRepository', () {
    final tRoutine = MockRoutine();
    final tBlock = MockBlock();
    when(tBlock.duration).thenReturn(60);
    when(tRoutine.id).thenReturn('1');
    when(tRoutine.blocks).thenReturn([tBlock]);

    final tSessionHistoryMap = [
      {
        'routine_id': '1',
        'routines': {'title': 'Morning Routine'},
        'completed_at': DateTime.now().toIso8601String(),
        'duration_secs': 60,
      }
    ];

    final tUserSession = UserSession(
      routineId: '1',
      routineTitle: 'Morning Routine',
      completedAt: DateTime.parse(tSessionHistoryMap[0]['completed_at'] as String),
      durationInSeconds: 60,
    );

    group('addSession', () {
      test('should call api.addSession with correct data', () async {
        // arrange
        when(mockProgressApi.addSession(any)).thenAnswer((_) async => Future.value());
        // act
        await progressRepository.addSession(tRoutine);
        // assert
        verify(mockProgressApi.addSession({
          'user_id': 'test-user-id',
          'routine_id': '1',
          'duration_secs': 60,
        })).called(1);
      });
    });

    group('getSessionHistory', () {
      test('should return a list of UserSession on success', () async {
        // arrange
        when(mockProgressApi.fetchSessionHistory()).thenAnswer((_) async => tSessionHistoryMap);
        // act
        final result = await progressRepository.getSessionHistory();
        // assert
        expect(result, [tUserSession]);
      });
    });

    group('watchUserStats', () {
      test('should return a stream of UserStats', () {
        // arrange
        when(mockProgressApi.watchUserProgress()).thenAnswer((_) => Stream.value(tSessionHistoryMap));
        // act
        final result = progressRepository.watchUserStats();
        // assert
        expect(
            result,
            emits(UserStats(
              dailyStreak: 1,
              totalMinutes: 1,
            )));
      });
    });

    group('getUserStats', () {
      test('should return UserStats on success', () async {
        // arrange
        when(mockProgressApi.fetchSessionHistory()).thenAnswer((_) async => tSessionHistoryMap);
        // act
        final result = await progressRepository.getUserStats();
        // assert
        expect(
            result,
            UserStats(
              dailyStreak: 1,
              totalMinutes: 1,
            ));
      });
    });
  });
}