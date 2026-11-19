import 'package:flutter/material.dart';

class HorizontalEdgeFade extends StatefulWidget {
  const HorizontalEdgeFade({
    super.key,
    required this.child,
    this.fadeWidth = 40,
  });

  final Widget child;
  final double fadeWidth;

  @override
  State<HorizontalEdgeFade> createState() => _HorizontalEdgeFadeState();
}

class _HorizontalEdgeFadeState extends State<HorizontalEdgeFade> {
  bool _fadeStart = false;
  bool _fadeEnd = false;

  bool _onMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.horizontal) return false;
    final fadeStart = metrics.extentBefore > 0.5;
    final fadeEnd = metrics.extentAfter > 0.5;
    if (fadeStart != _fadeStart || fadeEnd != _fadeEnd) {
      setState(() {
        _fadeStart = fadeStart;
        _fadeEnd = fadeEnd;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _onMetrics(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => _onMetrics(n.metrics),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _fadeStart ? 1 : 0),
          duration: const Duration(milliseconds: 200),
          builder: (context, start, _) => TweenAnimationBuilder<double>(
            tween: Tween(end: _fadeEnd ? 1 : 0),
            duration: const Duration(milliseconds: 200),
            builder: (context, end, child) => ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => _gradient(bounds, start, end),
              child: child,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Shader _gradient(Rect bounds, double start, double end) {
    final width = bounds.width;
    final stop = width <= 0 ? 0.0 : (widget.fadeWidth / width).clamp(0.0, 0.5);
    return LinearGradient(
      colors: [
        Colors.black.withValues(alpha: 1 - start),
        Colors.black,
        Colors.black,
        Colors.black.withValues(alpha: 1 - end),
      ],
      stops: [0, stop, 1 - stop, 1],
    ).createShader(bounds);
  }
}
