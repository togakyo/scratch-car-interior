import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws the gift-wrap cover layer and erases where the user has scratched.
/// Uses BlendMode.dstOut inside a saveLayer to punch holes in the cover.
class ScratchPainter extends CustomPainter {
  final List<Offset> points;
  final double brushRadius;
  final int seed; // for deterministic star positions

  const ScratchPainter({
    required this.points,
    required this.brushRadius,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Compositing layer: everything drawn here is composited as a unit.
    canvas.saveLayer(Offset.zero & size, Paint());

    _drawCover(canvas, size);

    // Erase scratched areas
    final erase = Paint()..blendMode = BlendMode.dstOut;
    for (final p in points) {
      canvas.drawCircle(p, brushRadius, erase);
    }

    canvas.restore();
  }

  void _drawCover(Canvas canvas, Size size) {
    // Silver base gradient
    final baseShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFFD8D8E8), Color(0xFF9898B8), Color(0xFFD0D0E0)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = baseShader);

    // Subtle shimmer streaks
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = size.width * 0.06;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.1 + i * 0.2);
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * 0.4, size.height),
          shimmerPaint);
    }

    // Red ribbon cross
    final ribbonPaint = Paint()
      ..color = const Color(0xFFEE2255)
      ..strokeWidth = size.height * 0.06;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), ribbonPaint);
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), ribbonPaint);

    // Gold ribbon border on edges of red strips
    final goldPaint = Paint()
      ..color = const Color(0xFFFFCC00)
      ..strokeWidth = size.height * 0.012;
    final rHalf = size.height * 0.03;
    for (final dy in [-rHalf, rHalf]) {
      canvas.drawLine(
        Offset(0, size.height / 2 + dy),
        Offset(size.width, size.height / 2 + dy),
        goldPaint,
      );
    }
    final rHalfW = size.width * 0.03;
    for (final dx in [-rHalfW, rHalfW]) {
      canvas.drawLine(
        Offset(size.width / 2 + dx, 0),
        Offset(size.width / 2 + dx, size.height),
        goldPaint,
      );
    }

    // Star pattern (deterministic)
    _drawStarPattern(canvas, size);

    // "SCRATCH!" label hint in centre
    _drawLabel(canvas, size);
  }

  void _drawStarPattern(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.30);
    for (var i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      _miniStar(canvas, Offset(x, y), 8 + rng.nextDouble() * 6, starPaint);
    }
  }

  void _miniStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5 - math.pi / 2;
      final rad = i.isEven ? r : r * 0.42;
      final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLabel(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'こすってね！',
        style: TextStyle(
          fontSize: size.width * 0.065,
          fontWeight: FontWeight.w900,
          color: Colors.white.withValues(alpha: 0.55),
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2 - size.height * 0.04,
      ),
    );
  }

  @override
  bool shouldRepaint(ScratchPainter old) =>
      old.points.length != points.length ||
      (points.isNotEmpty && old.points.last != points.last);
}
