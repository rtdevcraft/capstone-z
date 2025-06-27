import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/features/reports/data/report_repository.dart';

// Fake SupabaseClient for testing
class FakeSupabaseClient extends Fake implements SupabaseClient {
  final GoTrueClient _auth;
  dynamic _data;

  FakeSupabaseClient(this._auth);

  set nextResponse(dynamic data) {
    _data = data;
  }

  @override
  GoTrueClient get auth => _auth;

  @override
  SupabaseQueryBuilder from(String table) {
    return FakeSupabaseQueryBuilder(_data);
  }
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  User? _currentUser;

  set currentUser(User? user) {
    _currentUser = user;
  }

  @override
  User? get currentUser => _currentUser;
}


class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic _data;

  FakeSupabaseQueryBuilder(this._data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
      [String columns = '*']) {
    return FakePostgrestFilterBuilder(_data);
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final dynamic _data;

  FakePostgrestFilterBuilder(this._data);

  @override
  PostgrestFilterBuilder<T> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<T> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<T> lte(String column, dynamic value) => this;

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T value) onValue, {
    Function? onError,
  }) async {
    return onValue(_data as T);
  }
}

void main() {
  late FakeSupabaseClient fakeSupabaseClient;
  late FakeGoTrueClient fakeGoTrueClient;
  late ReportRepository reportRepository;

  setUp(() {
    fakeGoTrueClient = FakeGoTrueClient();
    fakeSupabaseClient = FakeSupabaseClient(fakeGoTrueClient);
    reportRepository = ReportRepository(fakeSupabaseClient);
  });

  group('ReportRepository', () {
    final testUser = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final dateRange = DateTimeRange(
      start: DateTime(2023, 1, 1),
      end: DateTime(2023, 1, 31),
    );

    test('getCompletionReport returns a valid report on success', () async {
      final mockResponse = [
        {
          'id': '1',
          'user_id': 'test-user-id',
          'completed_at': '2023-01-15T10:00:00Z',
          'duration_secs': 120,
          'routines': {'title': 'Morning Stretch'}
        }
      ];

      fakeGoTrueClient.currentUser = testUser;
      fakeSupabaseClient.nextResponse = mockResponse;

      final report = await reportRepository.getCompletionReport(dateRange);

      expect(report.rows, isNotEmpty);
      expect(report.rows.first.routineTitle, 'Morning Stretch');
      expect(report.rows.first.duration, const Duration(seconds: 120));
    });

    test('getCompletionReport throws exception when user is not authenticated',
        () async {
      fakeGoTrueClient.currentUser = null;

      expect(
        () => reportRepository.getCompletionReport(dateRange),
        throwsA(isA<Exception>()),
      );
    });
  });
}