import 'package:flutter/material.dart';
import 'package:noble_pasteur/core/constants/app_colors.dart';

class AnimatedPulseRing extends StatefulWidget {
  final double size;
  final bool isPulsing;
  final Color color;

  const AnimatedPulseRing({
    super.key,
    required this.size,
    this.isPulsing = true,
    this.color = AppColors.emergencyRed,
  });

  @override
  State<AnimatedPulseRing> createState() => _AnimatedPulseRingState();
}

class _AnimatedPulseRingState extends State<AnimatedPulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isPulsing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedPulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPulsing) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Wave 1
            _buildRing(
              scale: 1.0 + (_controller.value * 0.45),
              opacity: (1.0 - _controller.value) * 0.35,
            ),
            // Wave 2
            _buildRing(
              scale: 1.0 + (((_controller.value + 0.5) % 1.0) * 0.45),
              opacity: (1.0 - ((_controller.value + 0.5) % 1.0)) * 0.35,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRing({required double scale, required double opacity}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
