import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/features/routine_editor/presentation/routine_editor_controller.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/core/services/logger_service.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';

// Provider to fetch all routines from the repository
final allRoutinesProvider = FutureProvider<List<Routine>>((ref) {
  logger.i('allRoutinesProvider: building');
  return ref.watch(routineRepositoryProvider).getAllRoutines();
});

// State provider to hold the currently selected category filter
final categoryFilterProvider =
    StateProvider<RoutineCategory?>((ref) => null);

// State provider to hold the current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to combine category and search filters
final filteredRoutinesProvider = Provider<List<Routine>>((ref) {
  final categoryFilter = ref.watch(categoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final List<Routine> routines = ref.watch(allRoutinesProvider).when(
        data: (data) => data,
        loading: () => [],
        error: (_, _) => [],
      );

  // Apply category filter first
  final categoryFilteredRoutines = (categoryFilter == null || categoryFilter == RoutineCategory.all)
      ? routines
      : routines.where((routine) => routine.category == categoryFilter).toList();

  // Then apply search filter
  if (searchQuery.isEmpty) {
    return categoryFilteredRoutines;
  }

  final lowerCaseQuery = searchQuery.toLowerCase();
  return categoryFilteredRoutines.where((routine) {
    final titleMatch = routine.title.toLowerCase().contains(lowerCaseQuery);
    final descriptionMatch =
        routine.description.toLowerCase().contains(lowerCaseQuery);
    return titleMatch || descriptionMatch;
  }).toList();
});

class ContentLibraryScreen extends ConsumerStatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  ConsumerState<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends ConsumerState<ContentLibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutines = ref.watch(filteredRoutinesProvider);
    final allRoutinesAsync = ref.watch(allRoutinesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Library'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search for routines...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
          // Category Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(category: null),
                ...RoutineCategory.values
                    .where((c) => c != RoutineCategory.all)
                    .map((category) => _CategoryChip(category: category))
              ],
            ),
          ),
          // Routine List
          Expanded(
            child: allRoutinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (_) {
                if (filteredRoutines.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text('No routines found matching your search.'),
                  );
                }
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = (screenWidth / 200).floor().clamp(2, 4);
                return GridView.builder(
                  key: const Key('routine_grid_view'),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRoutines.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final routine = filteredRoutines[index];
                    return _RoutineCard(routine: routine);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push('/create-routine'),
        child: const Icon(AppIcons.add),
      ),
    );
  }
}

// A widget for the category filter chips
class _CategoryChip extends ConsumerWidget {
  const _CategoryChip({required this.category});
  final RoutineCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(categoryFilterProvider);
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(category?.displayName ?? 'All'),
        selected: isSelected,
        onSelected: (selected) {
          if (isSelected) {
            ref.read(categoryFilterProvider.notifier).state = null;
          } else {
            ref.read(categoryFilterProvider.notifier).state = category;
          }
        },
      ),
    );
  }
}

// A widget for displaying a single routine in a card
class _RoutineCard extends ConsumerWidget {
  const _RoutineCard({required this.routine});
  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDuration =
        routine.blocks.fold(0, (sum, block) => sum + block.duration) ~/ 60;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/player/${routine.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.category?.displayName.toUpperCase() ?? '',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                routine.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  routine.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Row(
                   children: [
                     const Icon(AppIcons.timerOutlined, size: 16),
                     const SizedBox(width: 4),
                     Text('$totalDuration min'),
                   ],
                 ),
                 if (routine.userId != null)
                   Row(
                     children: [
                       IconButton(
                         icon: const Icon(AppIcons.edit),
                         onPressed: () => GoRouter.of(context)
                             .push('/edit-routine/${routine.id}'),
                       ),
                       IconButton(
                         icon: const Icon(AppIcons.delete),
                         onPressed: () async {
                           final confirm = await showDialog<bool>(
                             context: context,
                             builder: (context) => AlertDialog(
                               title: const Text('Delete Routine'),
                               content: const Text(
                                   'Are you sure you want to delete this routine?'),
                               actions: [
                                 TextButton(
                                   onPressed: () =>
                                       Navigator.of(context).pop(false),
                                   child: const Text('Cancel'),
                                 ),
                                 TextButton(
                                   onPressed: () =>
                                       Navigator.of(context).pop(true),
                                   child: const Text('Delete'),
                                 ),
                               ],
                             ),
                           );
                           if (confirm ?? false) {
                             ref
                                 .read(
                                     routineEditorControllerProvider.notifier)
                                 .deleteRoutine(routine.id);
                           }
                         },
                       ),
                     ],
                   ),
               ],
             ),
           ],
         ),
       ),
     ),
   );
 }
}