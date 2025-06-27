import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Gradient? gradient;
  final double widthFactor;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.gradient,
    this.widthFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * widthFactor,
      decoration: BoxDecoration(
        gradient: gradient ??
            const LinearGradient(
              colors: [
                Color.fromARGB(255, 36, 84, 150),
                Color.fromARGB(255, 51, 133, 107),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(12), // More rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black38, // A slightly darker shadow
            offset: Offset(1.0, 1.0), // A more pronounced offset
            blurRadius: 4.0, // A softer blur
          ),
        ],
      ),
      child: RawMaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: DefaultTextStyle(
          style: GoogleFonts.lexendExa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: const [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black26,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}