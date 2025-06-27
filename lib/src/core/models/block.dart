/// Represents a single step or block within a wellness routine.
///
/// Each block has a piece of instructional text and a specific duration
/// for which that instruction should be displayed or performed.
class Block {
  const Block({
    this.id,
    required this.routineId,
    required this.instruction,
    required this.duration,
    required this.order,
  });

  /// The unique identifier for the block.
  final String? id;

  /// The ID of the routine this block belongs to.
  final String routineId;

  /// The instructional text to be displayed to the user.
  /// e.g., "Breathe in for 4 seconds".
  final String instruction;

  /// The duration for this block in seconds.
  final int duration;

  /// The order of the block in the routine sequence.
  final int order;

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'],
      routineId: json['routine_id'],
      instruction: json['instruction'],
      duration: json['duration'],
      order: json['block_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routine_id': routineId,
      'instruction': instruction,
      'duration': duration,
      'block_order': order,
    };
  }

  Block copyWith({
    String? id,
    String? routineId,
    String? instruction,
    int? duration,
    int? order,
  }) {
    return Block(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      instruction: instruction ?? this.instruction,
      duration: duration ?? this.duration,
      order: order ?? this.order,
    );
  }
}