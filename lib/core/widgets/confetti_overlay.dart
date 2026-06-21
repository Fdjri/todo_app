import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_assets.dart';

/// Confetti overlay that plays a Lottie confetti animation
class ConfettiOverlay extends StatefulWidget {
  final bool play;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    required this.play,
    this.onComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.play) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          AppAssets.lottieConfetti,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().then((_) {
                widget.onComplete?.call();
              });
          },
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
