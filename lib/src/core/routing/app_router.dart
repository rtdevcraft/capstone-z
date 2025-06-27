
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenigo/src/core/auth/auth_state_provider.dart';
import 'package:zenigo/src/features/auth/presentation/auth_screen.dart';
import 'package:zenigo/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:zenigo/src/features/library/presentation/content_library_screen.dart';
import 'package:zenigo/src/features/player/presentation/routine_player_screen.dart';
import 'package:zenigo/src/features/progress/presentation/progress_screen.dart';
import 'package:zenigo/src/features/reports/presentation/report_editor_screen.dart';
import 'package:zenigo/src/features/reports/presentation/reports_screen.dart';
import 'package:zenigo/src/features/routine_editor/presentation/routine_editor_screen.dart';

class _RefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RefreshNotifier();
  ref.listen(authStateProvider, (_, _) => refreshNotifier.refresh());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      // If the auth state is loading, don't redirect. This prevents a flash of
      // the login screen when the user is already authenticated.
      if (authState.isLoading) {
        return null;
      }
      final isAuthenticated = authState.valueOrNull?.session != null;
      final isLoggingIn = state.matchedLocation == '/auth';

      // If the user is not logged in and not on the auth screen, redirect to it.
      if (!isAuthenticated && !isLoggingIn) return '/auth';

      // If the user is logged in and on the auth screen, redirect to the dashboard.
      if (isAuthenticated && isLoggingIn) return '/';

      // No redirect needed.
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const ContentLibraryScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/player/:routineId',
        builder: (context, state) {
          final routineId = state.pathParameters['routineId']!;
          return RoutinePlayerScreen(routineId: routineId);
        },
      ),
      GoRoute(
        path: '/edit-routine/:routineId',
        builder: (context, state) {
          final routineId = state.pathParameters['routineId']!;
          return RoutineEditorScreen(routineId: routineId);
        },
      ),
      GoRoute(
        path: '/create-routine',
        builder: (context, state) => const RoutineEditorScreen(routineId: null),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/create-report',
        builder: (context, state) => const ReportEditorScreen(),
      ),
    ],
  );
});