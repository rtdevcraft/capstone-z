import 'package:flutter_test/flutter_test.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';

void main() {
  group('Block Model', () {
    final testBlock = Block(
      id: 'block-1',
      routineId: 'routine-1',
      instruction: 'Test Instruction',
      duration: 60,
      order: 1,
    );

    test('copyWith creates a copy with updated values', () {
      final updatedBlock = testBlock.copyWith(duration: 120);
      expect(updatedBlock.instruction, 'Test Instruction');
      expect(updatedBlock.duration, 120);
      expect(updatedBlock.order, 1);
    });

    test('fromJson creates a valid Block object from a map', () {
      final json = {
        'id': 'block-2',
        'routine_id': 'routine-1',
        'instruction': 'From JSON',
        'duration': 30,
        'block_order': 2,
      };
      final block = Block.fromJson(json);
      expect(block.instruction, 'From JSON');
      expect(block.duration, 30);
      expect(block.order, 2);
    });

    test('toJson creates a valid map from a Block object', () {
      final json = testBlock.toJson();
      expect(json['instruction'], 'Test Instruction');
      expect(json['duration'], 60);
      expect(json['block_order'], 1);
    });
  });

  group('Routine Model', () {
    final testRoutine = Routine(
      id: 'routine-1',
      title: 'Test Routine',
      description: 'A routine for testing.',
      category: RoutineCategory.mindfulMorning,
      blocks: const [
        Block(
            id: 'b1',
            routineId: 'routine-1',
            instruction: 'Block 1',
            duration: 10,
            order: 0),
        Block(
            id: 'b2',
            routineId: 'routine-1',
            instruction: 'Block 2',
            duration: 20,
            order: 1),
      ],
    );

    test('copyWith creates a copy with updated values', () {
      final updatedRoutine = testRoutine.copyWith(title: 'Updated Title');
      expect(updatedRoutine.id, 'routine-1');
      expect(updatedRoutine.title, 'Updated Title');
      expect(updatedRoutine.description, 'A routine for testing.');
      expect(updatedRoutine.category, RoutineCategory.mindfulMorning);
      expect(updatedRoutine.blocks.length, 2);
    });

    test('fromJson creates a valid Routine object from a map', () {
      final json = {
        'id': 'routine-2',
        'title': 'JSON Routine',
        'description': 'From JSON.',
        'category': 'eveningWindDown',
        'blocks': [
          {'instruction': 'JSON Block', 'duration': 5, 'block_order': 0}
        ],
      };
      final routine = Routine.fromJson(json);
      expect(routine.id, 'routine-2');
      expect(routine.title, 'JSON Routine');
      expect(routine.description, 'From JSON.');
      expect(routine.category, RoutineCategory.eveningWindDown);
      expect(routine.blocks.length, 1);
      expect(routine.blocks.first.instruction, 'JSON Block');
    });

    test('toJson creates a valid map from a Routine object', () {
      final json = testRoutine.toJson();
      expect(json['id'], 'routine-1');
      expect(json['title'], 'Test Routine');
      expect(json['description'], 'A routine for testing.');
      expect(json['category'], 'mindfulMorning');
      expect((json['blocks'] as List).length, 2);
    });
  });
}