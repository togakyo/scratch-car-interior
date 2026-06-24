import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/car_config.dart';

enum PlayAnim { none, horn, lights, wash, spin, color }

/// Draws an original chibi car in a 480 × 280 logical viewport.
class CarPainter extends CustomPainter {
  final CarConfig config;
  final PlayAnim anim;
  final double animVal; // 0–1
  // Extra particles (water drops / horn rings) passed from screen
  final List<_Drop> drops;

  const CarPainter({
    required this.config,
    this.anim = PlayAnim.none,
    this.animVal = 0,
    this.drops = const [],
  });

  // Logical canvas size the car is designed for
  static const double lw = 480;
  static const double lh = 280;

  @override
  void paint(Canvas canvas, Size size) {
    // Scale to fill, keeping aspect ratio
    final scale = math.min(size.width / lw, size.height / lh);
    final ox = (size.width - lw * scale) / 2;
    final oy = (size.height - lh * scale) / 2;
    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(scale);

    if (anim == PlayAnim.spin) {
      // Rotate around car centre
      canvas.translate(lw / 2, lh / 2 - 10);
      canvas.rotate(animVal * 4 * math.pi);
      canvas.translate(-lw / 2, -(lh / 2 - 10));
    }

    _drawCar(canvas);

    if (anim == PlayAnim.wash) _drawWashDrops(canvas);
    if (anim == PlayAnim.horn) _drawHornRings(canvas);

    canvas.restore();
  }

  // ── Main car body ────────────────────────────────────────────────────────

  void _drawCar(Canvas canvas) {
    final body = _getBodyColor();
    final roof = _getRoofColor();

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 218, 420, 28),
        const Radius.circular(14),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // ── Body ──────────────────────────────────────────────────────────────
    final bodyRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 92, 464, 138),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRRect, Paint()..color = body);

    // Body highlight (top edge)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 92, 464, 24),
        const Radius.circular(22),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // ── Roof / cab ────────────────────────────────────────────────────────
    final roofRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(85, 32, 310, 70),
      const Radius.circular(16),
    );
    canvas.drawRRect(roofRRect, Paint()..color = roof);

    // ── Windows ───────────────────────────────────────────────────────────
    final windowPaint = Paint()..color = const Color(0xAA9EDFFF);
    // Front window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(100, 40, 120, 60), const Radius.circular(9)),
      windowPaint,
    );
    // Rear window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(260, 40, 120, 60), const Radius.circular(9)),
      windowPaint,
    );
    // Window glare
    final glarePaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(105, 43, 50, 18), const Radius.circular(5)),
      glarePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(265, 43, 50, 18), const Radius.circular(5)),
      glarePaint,
    );

    // Interior: steering wheel
    canvas.drawCircle(
      const Offset(178, 70),
      13,
      Paint()
        ..color = const Color(0xFF333355)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // ── Door line ─────────────────────────────────────────────────────────
    canvas.drawLine(
      const Offset(240, 100),
      const Offset(240, 228),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..strokeWidth = 2,
    );

    // Door handles
    _drawHandle(canvas, body, 155, 155);
    _drawHandle(canvas, body, 255, 155);

    // ── Wheels ────────────────────────────────────────────────────────────
    _drawWheel(canvas, const Offset(122, 242));
    _drawWheel(canvas, const Offset(358, 242));

    // ── Lights ────────────────────────────────────────────────────────────
    final lightsOn = anim == PlayAnim.lights
        ? (math.sin(animVal * 10 * math.pi) * 0.5 + 0.5)
        : 0.0;
    _drawHeadlight(canvas, lightsOn);
    _drawTaillight(canvas, body, lightsOn);

    // ── Bumpers ───────────────────────────────────────────────────────────
    final bumpPaint = Paint()..color = roof;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 150, 16, 54), const Radius.circular(6)),
      bumpPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(462, 150, 16, 54), const Radius.circular(6)),
      bumpPaint,
    );

    // ── Antenna ───────────────────────────────────────────────────────────
    canvas.drawLine(
      const Offset(368, 32),
      const Offset(385, 4),
      Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(385, 4), 5, Paint()..color = const Color(0xFFDD2222));
  }

  void _drawHandle(Canvas canvas, Color body, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 44, 10), const Radius.circular(5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawWheel(Canvas canvas, Offset c) {
    // Tyre
    canvas.drawCircle(c, 42, Paint()..color = const Color(0xFF222233));
    // Hub
    canvas.drawCircle(c, 28, Paint()..color = const Color(0xFF888899));
    // Spokes
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      final p1 = c + Offset(math.cos(a) * 10, math.sin(a) * 10);
      final p2 = c + Offset(math.cos(a) * 27, math.sin(a) * 27);
      canvas.drawLine(p1, p2,
          Paint()
            ..color = const Color(0xFF555566)
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round);
    }
    // Centre cap
    canvas.drawCircle(c, 8, Paint()..color = const Color(0xFFCCCCDD));
  }

  void _drawHeadlight(Canvas canvas, double glow) {
    final baseColor = const Color(0xFFFFF5C0);
    if (glow > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(8, 102, 60, 34), const Radius.circular(14)),
        Paint()
          ..color = const Color(0xFFFFFF88).withValues(alpha: glow * 0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, 12 * glow),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(10, 104, 56, 30), const Radius.circular(12)),
      Paint()..color = Color.lerp(baseColor, Colors.white, glow * 0.5)!,
    );
  }

  void _drawTaillight(Canvas canvas, Color body, double glow) {
    final baseColor = const Color(0xFFFF3333);
    if (glow > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(412, 102, 60, 34), const Radius.circular(14)),
        Paint()
          ..color = Colors.red.withValues(alpha: glow * 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, 12 * glow),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(414, 104, 56, 30), const Radius.circular(12)),
      Paint()..color = Color.lerp(baseColor, const Color(0xFFFF8888), glow * 0.6)!,
    );
  }

  // ── Animation helpers ─────────────────────────────────────────────────────

  void _drawHornRings(Canvas canvas) {
    const origin = Offset(10, 119);
    for (var i = 0; i < 3; i++) {
      final t = (animVal * 2 - i * 0.28).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawCircle(
        origin,
        20 + t * 90,
        Paint()
          ..color = const Color(0xFFFFDD00).withValues(alpha: (1 - t) * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }
  }

  void _drawWashDrops(Canvas canvas) {
    final dropPaint = Paint()..color = const Color(0xFF66CCFF).withValues(alpha: 0.75);
    for (var i = 0; i < 22; i++) {
      final phase = (animVal + i / 22) % 1.0;
      final x = ((i * 23 + 40) % 400) + 40.0;
      final y = phase * (lh + 20) - 20;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 6, height: 14),
          dropPaint);
    }
  }

  // ── Color helpers ─────────────────────────────────────────────────────────

  Color _getBodyColor() {
    if (anim != PlayAnim.color) return config.bodyColor;
    final hsl = HSLColor.fromColor(config.bodyColor);
    return hsl.withHue((hsl.hue + animVal * 360) % 360).toColor();
  }

  Color _getRoofColor() {
    if (anim != PlayAnim.color) return config.roofColor;
    final hsl = HSLColor.fromColor(config.roofColor);
    return hsl.withHue((hsl.hue + animVal * 360) % 360).toColor();
  }

  @override
  bool shouldRepaint(CarPainter old) =>
      old.anim != anim ||
      old.animVal != animVal ||
      old.config.bodyColor != config.bodyColor ||
      old.drops.length != drops.length;
}

class _Drop {
  final Offset pos;
  const _Drop(this.pos);
}
