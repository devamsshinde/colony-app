import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom animated radar/sonar widget for location loading animation.
/// Shows concentric circles pulsing outward with dots representing nearby people.
class LocationRadarWidget extends StatefulWidget {
  /// The size of the radar widget
  final double size;

  /// Color of the radar circles (default: green)
  final Color color;

  /// Number of concentric circles (default: 3)
  final int circleCount;

  /// Duration of one pulse cycle
  final Duration pulseDuration;

  /// Whether to show nearby dots
  final bool showNearbyDots;

  /// Number of nearby dots to show
  final int nearbyDotsCount;

  /// Custom center widget (e.g., user avatar)
  final Widget? centerWidget;

  const LocationRadarWidget({
    super.key,
    this.size = 200,
    this.color = Colors.green,
    this.circleCount = 3,
    this.pulseDuration = const Duration(seconds: 2),
    this.showNearbyDots = true,
    this.nearbyDotsCount = 5,
    this.centerWidget,
  });

  @override
  State<LocationRadarWidget> createState() => _LocationRadarWidgetState();
}

class _LocationRadarWidgetState extends State<LocationRadarWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sweepController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sweepAnimation;

  late List<_NearbyDot> _nearbyDots;

  @override
  void initState() {
    super.initState();

    // Pulse animation for circles expanding outward
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );

    // Sweep animation for radar line
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _sweepAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.linear,
    );

    // Start animations
    _pulseController.repeat();
    _sweepController.repeat();

    // Generate random nearby dots
    _generateNearbyDots();
  }

  void _generateNearbyDots() {
    final random = math.Random();
    _nearbyDots = List.generate(widget.nearbyDotsCount, (index) {
      return _NearbyDot(
        angle: random.nextDouble() * 2 * math.pi,
        distance: 0.3 + random.nextDouble() * 0.5, // 30% to 80% from center
        size: 4 + random.nextDouble() * 4,
        delay: random.nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _sweepAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(
              pulseValue: _pulseAnimation.value,
              sweepValue: _sweepAnimation.value,
              color: widget.color,
              circleCount: widget.circleCount,
              nearbyDots: widget.showNearbyDots ? _nearbyDots : [],
            ),
            child: Center(child: widget.centerWidget ?? _buildDefaultCenter()),
          );
        },
      ),
    );
  }

  Widget _buildDefaultCenter() {
    return Container(
      width: widget.size * 0.2,
      height: widget.size * 0.2,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.location_on,
        color: Colors.white,
        size: widget.size * 0.1,
      ),
    );
  }
}

/// Custom painter for the radar animation
class _RadarPainter extends CustomPainter {
  final double pulseValue;
  final double sweepValue;
  final Color color;
  final int circleCount;
  final List<_NearbyDot> nearbyDots;

  _RadarPainter({
    required this.pulseValue,
    required this.sweepValue,
    required this.color,
    required this.circleCount,
    required this.nearbyDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw concentric circles with pulse effect
    for (int i = 0; i < circleCount; i++) {
      final baseRadius = maxRadius * (0.3 + (i * 0.25));
      final pulseOffset = (pulseValue + (i * 0.15)) % 1.0;
      final radius = baseRadius * (0.8 + pulseOffset * 0.4);

      final opacity = (1 - pulseOffset) * 0.5;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw radar sweep line
    final sweepAngle = sweepValue * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi / 2,
        colors: [
          color.withOpacity(0),
          color.withOpacity(0.3),
          color.withOpacity(0.5),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(sweepAngle - math.pi / 4),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius * 0.9, sweepPaint);

    // Draw nearby dots
    for (final dot in nearbyDots) {
      final dotOpacity =
          math.sin((pulseValue + dot.delay) * math.pi) * 0.5 + 0.5;
      final dotX = center.dx + math.cos(dot.angle) * maxRadius * dot.distance;
      final dotY = center.dy + math.sin(dot.angle) * maxRadius * dot.distance;

      final dotPaint = Paint()
        ..color = color.withOpacity(dotOpacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), dot.size, dotPaint);

      // Draw glow around dot
      final glowPaint = Paint()
        ..color = color.withOpacity(dotOpacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(dotX, dotY), dot.size * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return pulseValue != oldDelegate.pulseValue ||
        sweepValue != oldDelegate.sweepValue;
  }
}

/// Data class for nearby dots on the radar
class _NearbyDot {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  _NearbyDot({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

/// A simpler version of the radar widget for smaller spaces
class LocationRadarMini extends StatelessWidget {
  final double size;
  final Color color;

  const LocationRadarMini({
    super.key,
    this.size = 60,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return LocationRadarWidget(
      size: size,
      color: color,
      circleCount: 2,
      showNearbyDots: false,
      pulseDuration: const Duration(milliseconds: 1500),
    );
  }
}
