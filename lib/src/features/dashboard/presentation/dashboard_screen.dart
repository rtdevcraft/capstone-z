import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenigo/src/core/auth/auth_repository.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';
import 'package:zenigo/src/shared/widgets/gradient_button.dart';

final userStatsProvider = StreamProvider<UserStats>((ref) {
  final progressRepo = ref.watch(progressRepositoryProvider);
  return progressRepo.watchUserStats();
});

// Provider to fetch all dashboard data in parallel
final dashboardDataProvider =
    StreamProvider<({Routine? dailyPick, UserStats userStats})>(
  (ref) async* {
    final routineRepo = ref.watch(routineRepositoryProvider);
    final userStatsStream = ref.watch(progressRepositoryProvider).watchUserStats();

    
    final Routine? dailyPick = await routineRepo.getAllRoutines().then((r) => r.isNotEmpty ? r.first : null);

    // Yield combined data for each userStats emission
    await for (final userStats in userStatsStream) {
      yield (dailyPick: dailyPick, userStats: userStats);
    }
  },
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: const Key('dashboard_screen'),
      appBar: AppBar(
        title: const Text('Your Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.barChartOutlined),
            tooltip: 'View Progress',
            onPressed: () {
              GoRouter.of(context).push('/progress');
            },
          ),
          IconButton(
            key: const Key('sign_out_button'),
            icon: const Icon(AppIcons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'User Guide',
            onPressed: () {
              GoRouter.of(context).push('/guide');
            },
          ),
        ],
      ),
      body: dashboardData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final dailyPick = data.dailyPick;
          final userStats = data.userStats;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Stats Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: userStats.dailyStreak.toString(),
                    label: 'Day Streak',
                  ),
                  _StatItem(
                    value: userStats.totalMinutes.toString(),
                    label: 'Total Minutes',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Daily Pick Section
              if (dailyPick != null)
                _DailyPickCard(routine: dailyPick)
              else
                const Center(child: Text('No daily pick available.')),

              const SizedBox(height: 32),

              // Library Access Button
              GradientButton(
                onPressed: () {
                  GoRouter.of(context).push('/library');
                },
                widthFactor: 0.5,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.libraryBooksOutlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Browse Full Library'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                onPressed: () {
                  GoRouter.of(context).push('/reports');
                },
                widthFactor: 0.5,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.analyticsOutlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text('View Reports'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// A widget for the "Daily Pick" card
class _DailyPickCard extends StatelessWidget {
  const _DailyPickCard({required this.routine});
  final Routine routine;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(128)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Pick',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              routine.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              routine.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            GradientButton(
              onPressed: () {
                GoRouter.of(context).push('/player/${routine.id}');
              },
              widthFactor: 0.5,
              child: const Text('Start Session'),
            ),
          ],
        ),
      ),
    );
  }
}

// A widget for displaying a single user statistic
class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}