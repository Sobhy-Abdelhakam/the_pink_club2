import 'package:flutter/material.dart';

class AnimatedBackgroundGradient extends StatefulWidget {
  final Color color;

  const AnimatedBackgroundGradient({super.key, required this.color});

  @override
  State<AnimatedBackgroundGradient> createState() =>
      _AnimatedBackgroundGradientState();
}

class _AnimatedBackgroundGradientState extends State<AnimatedBackgroundGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: FractionalOffset.center,
              startAngle: 0.0,
              endAngle: _animation.value * 2 * 3.141592653589793,
              colors: [
                widget.color.withOpacity(0.8),
                widget.color.withOpacity(0.6),
                widget.color.withOpacity(0.4),
                widget.color.withOpacity(0.6),
                widget.color.withOpacity(0.8),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        );
      },
    );
  }
}