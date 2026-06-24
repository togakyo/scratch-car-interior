import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfettiParticle {
  Offset pos;
  Offset vel;
  double rot;
  double rotSpeed;
  Color color;
  double w, h;
  double life; // 1→0

  ConfettiParticle({
    required this.pos,
    required this.vel,
    required this.rot,
    required this.rotSpeed,
    required this.color,
    required this.w,
    required this.h,
    this.life = 1.0,
  });

  static ConfettiParticle spawn(Size size, math.Random rng) {
    return ConfettiParticle(
      pos: Offset(rng.nextDouble() * size.width, -20),
      vel: Offset((rng.nextDouble() - 0.5) * 180, 180 + rng.nextDouble() * 220),
      rot: rng.nextDouble() * math.pi * 2,
      rotSpeed: (rng.nextDouble() - 0.5) * 6,
      color: AppColors.confetti[rng.nextInt(AppColors.confetti.length)],
      w: 8 + rng.nextDouble() * 8,
      h: 5 + rng.nextDouble() * 5,
    );
  }

  void update(double dt) {
    pos += vel * dt;
    vel = Offset(vel.dx * 0.98, vel.dy + 200 * dt); // gravity
    rot += rotSpeed * dt;
    life -= dt * 0.55;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  const ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.life <= 0) continue;
      canvas.save();
      canvas.translate(p.pos.dx, p.pos.dy);
      canvas.rotate(p.rot);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
        Paint()..color = p.color.withValues(alpha: p.life.clamp(0, 1)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => true;
}

/// Small sparkle particles that follow the finger during scratching.
class SparkleParticle {
  Offset pos;
  double life; // 1→0
  Color color;
  double radius;

  SparkleParticle({
    required this.pos,
    required this.color,
    required this.radius,
    this.life = 1.0,
  });

  void update(double dt) => life -= dt * 3.5;
}

class SparklePainter extends CustomPainter {
  final List<SparkleParticle> particles;
  const SparklePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.life <= 0) continue;
      final a = p.life.clamp(0.0, 1.0);
      canvas.drawCircle(
        p.pos,
        p.radius * a,
        Paint()
          ..color = p.color.withValues(alpha: a * 0.85)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(SparklePainter old) => true;
}
