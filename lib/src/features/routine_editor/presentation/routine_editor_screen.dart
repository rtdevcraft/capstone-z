import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenigo/src/core/auth/auth_state_provider.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/features/routine_editor/presentation/routine_editor_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:zenigo/src/core/services/logger_service.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';
import 'package:zenigo/src/shared/widgets/gradient_button.dart';

final routineProvider =
    FutureProvider.autoDispose.family<Routine?, String?>((ref, routineId) {
  if (routineId == null) {
    return Future.value(Routine(
      id: const Uuid().v4(),
      title: '',
      description: '',
      category: null,
      blocks: [],
    ));
  }
  return ref.watch(routineRepositoryProvider).getRoutineById(routineId);
});

class RoutineEditorScreen extends ConsumerStatefulWidget {
  final String? routineId;

  const RoutineEditorScreen({super.key, this.routineId});

  @override
  ConsumerState<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late Routine _routine;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(routineProvider(widget.routineId));

    return routineAsync.when(
      data: (routine) {
        if (routine == null) {
          return const Scaffold(
            body: Center(child: Text('Routine not found.')),
          );
        }
        if (!_isInitialized) {
          _routine = routine;
          _isInitialized = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.routineId == null ? 'Create Routine' : 'Edit Routine'),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.save),
                onPressed: _saveRoutine,
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  initialValue: _routine.title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _routine = _routine.copyWith(title: value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _routine.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) =>
                      _routine = _routine.copyWith(description: value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RoutineCategory?>(
                  value: _routine.category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<RoutineCategory?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...RoutineCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _routine =
                          _routine.copyWith(category: value ?? RoutineCategory.values.first);
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text('Blocks', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildBlockList(),
                const SizedBox(height: 16),
                GradientButton(
                  onPressed: _addBlock,
                  widthFactor: 0.5,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Add Block'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBlockList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _routine.blocks.length,
      itemBuilder: (context, index) {
        final block = _routine.blocks[index];
        return Card(
          key: ValueKey(block.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(block.instruction),
            subtitle: Text('${block.duration} seconds'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(AppIcons.edit),
                  onPressed: () => _editBlock(index),
                ),
                IconButton(
                  icon: const Icon(AppIcons.delete),
                  onPressed: () => _removeBlock(index),
                ),
              ],
            ),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final block = _routine.blocks.removeAt(oldIndex);
          _routine.blocks.insert(newIndex, block);
        });
      },
    );
  }

  void _addBlock() {
    _editBlock(null);
  }

  void _editBlock(int? index) {
    final block =
        index == null ? null : _routine.blocks[index];
    showDialog<Block>(
      context: context,
      builder: (context) =>
          _BlockEditorDialog(block: block, routineId: _routine.id),
    ).then((newBlock) {
      if (newBlock != null) {
        setState(() {
          if (index == null) {
            _routine.blocks.add(newBlock.copyWith(id: const Uuid().v4()));
          } else {
            _routine.blocks[index] = newBlock;
          }
        });
      }
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _routine.blocks.removeAt(index);
    });
  }
Future<void> _saveRoutine() async {
  logger.i('Save button pressed');
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    logger.i('Form saved');

    final userId = ref.read(authStateProvider).value?.session?.user.id;
    if (userId == null) {
      logger.w('User not logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a routine.')),
      );
      return;
    }

    final routineToSave = _routine.copyWith(userId: userId);
    logger.i('Routine to save: $routineToSave');

    final controller = ref.read(routineEditorControllerProvider.notifier);
    logger.i('Calling saveRoutine controller method');
    final savedRoutine = await controller.saveRoutine(routineToSave);
    logger.i('saveRoutine controller method finished');

    if (savedRoutine != null && mounted) {
      ref.invalidate(routineProvider(savedRoutine.id));
      context.pop();
    } else {
      logger.e('Failed to save routine or widget is not mounted');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save routine. Please try again.')),
        );
      }
    }
  }
}
}

class _BlockEditorDialog extends StatefulWidget {
  final Block? block;
  final String routineId;

  const _BlockEditorDialog({this.block, required this.routineId});

  @override
  State<_BlockEditorDialog> createState() => _BlockEditorDialogState();
}

class _BlockEditorDialogState extends State<_BlockEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _instruction;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _instruction = widget.block?.instruction ?? '';
    _duration = widget.block?.duration ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.block == null ? 'Add Block' : 'Edit Block'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _instruction,
              decoration: const InputDecoration(labelText: 'Instruction'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter an instruction' : null,
              onSaved: (value) => _instruction = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _duration.toString(),
              decoration: const InputDecoration(labelText: 'Duration (seconds)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a duration';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) => _duration = int.parse(value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(
                Block(
                  id: widget.block?.id,
                  routineId: widget.routineId,
                  instruction: _instruction,
                  duration: _duration,
                  order: widget.block?.order ?? 0,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}