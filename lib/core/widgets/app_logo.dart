import 'package:flutter/material.dart';

/// Custom app logo widget — combines a book and a health heart icon
/// in a stylised glassmorphism rounded-square, like a premium app icon.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: OverflowBox(
          maxHeight: size * 1.4, // Allow it to be taller than the container
          alignment: Alignment.topCenter,
          child: Image.asset(
            'assets/images/logo.png',
            width: size,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF4A7BAF),
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
