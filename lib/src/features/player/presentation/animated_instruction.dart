import 'package:flutter/material.dart';

class AnimatedInstruction extends StatefulWidget {
  const AnimatedInstruction({
    super.key,
    required this.instruction,
    required this.duration,
  });

  final String instruction;
  final Duration duration;

  @override
  State<AnimatedInstruction> createState() => _AnimatedInstructionState();
}

class _AnimatedInstructionState extends State<AnimatedInstruction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedInstruction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.instruction != oldWidget.instruction) {
      _controller.duration = widget.duration;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - (_controller.value * 0.8), // Fade out
          child: Transform.translate(
            offset: Offset(0, -50 * _controller.value), // Move up
            child: Text(
              widget.instruction,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}