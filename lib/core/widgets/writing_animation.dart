import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WritingAnimation extends StatefulWidget {
  final String text;
  const WritingAnimation({super.key, this.text = 'Sedang menulis...'});

  @override
  State<WritingAnimation> createState() => _WritingAnimationState();
}

class _WritingAnimationState extends State<WritingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_animation.value, _animation.value * -0.5),
              child: Transform.rotate(
                angle: _animation.value * 0.05,
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 80,
                  color: AppColors.primaryTeal,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
