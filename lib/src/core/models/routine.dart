import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine_category.dart';

/// Represents a complete wellness routine composed of a sequence of blocks.
class Routine {
  const Routine({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    this.category,
    this.blocks = const [], // Default to empty list, will be loaded separately
  });

  /// A unique identifier for the routine.
  final String id;

  /// The ID of the user who created this routine. Null for default routines.
  final String? userId;

  /// The title of the routine, e.g., "Mindful Morning Flow".
  final String title;

  /// A brief description of the routine's purpose or focus.
  final String description;

  /// The category this routine belongs to.
  final RoutineCategory? category;

  /// The sequence of blocks that make up this routine.
  final List<Block> blocks;

  factory Routine.fromJson(Map<String, dynamic> json) {
    final blocksData = json['blocks'] as List<dynamic>?;
    final routineId = json['id'] as String; // Get the routine ID
    final blocks = blocksData != null
        ? blocksData
            .map((blockJson) => Block.fromJson(
                Map<String, dynamic>.from(blockJson as Map)
                  ..putIfAbsent('routine_id', () => routineId))) // Inject routine_id
            .toList()
        : <Block>[];

    // Sort blocks by their order
    blocks.sort((a, b) => a.order.compareTo(b.order));

    return Routine(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'] == null
          ? null
          : RoutineCategory.values
              .firstWhere((e) => e.name == json['category']),
      blocks: blocks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category?.name,
      'user_id': userId,
      // 'created_at': (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
      'blocks': blocks.map((b) => b.toJson()).toList(),
    };
  }

  Routine copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    RoutineCategory? category,
    List<Block>? blocks,
  }) {
    return Routine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      blocks: blocks ?? this.blocks,
    );
  }
}