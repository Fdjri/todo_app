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
      // Only call forward if the Lottie composition has already been loaded
      // and duration is set. If not yet loaded, onLoaded will handle the
      // first play. Subsequent replays come through here.
      if (_controller.duration != null) {
        _controller.forward(from: 0).then((_) {
          widget.onComplete?.call();
        });
      }
      // If duration is null → Lottie not loaded yet → onLoaded will play it
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
            // Set duration first, then play if widget.play is still true
            _controller.duration = composition.duration;
            if (widget.play) {
              _controller.forward(from: 0).then((_) {
                widget.onComplete?.call();
              });
            }
          },
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
