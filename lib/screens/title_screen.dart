import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/car_config.dart';
import '../painters/car_painter.dart';
import '../theme/app_colors.dart';

class TitleScreen extends StatefulWidget {
  final VoidCallback onStart;
  const TitleScreen({super.key, required this.onStart});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _colorCtrl;
  late AnimationController _starCtrl;
  int _colorIdx = 0;

  static final _carColors = AppColors.carColors;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _bounceCtrl.repeat(reverse: true);

    _colorCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _colorCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _colorIdx = (_colorIdx + 1) % _carColors.length);
        _colorCtrl.forward(from: 0);
      }
    });
    _colorCtrl.forward();

    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _colorCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_bounceCtrl, _colorCtrl, _starCtrl]),
          builder: (context, _) {
            final carCfg = CarConfig(
              bodyColor: Color.lerp(
                _carColors[_colorIdx],
                _carColors[(_colorIdx + 1) % _carColors.length],
                _colorCtrl.value,
              )!,
              dirtSeed: 0,
            );
            final bounceOffset = math.sin(_bounceCtrl.value * math.pi) * 14;

            return Stack(
              children: [
                // Background stars
                CustomPaint(
                  painter: _StarsBgPainter(_starCtrl.value),
                  child: const SizedBox.expand(),
                ),

                // Content
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Title
                      _RainbowTitle('SCRATCH', 52, _colorCtrl.value),
                      const SizedBox(height: 4),
                      _RainbowTitle('CAR！', 48, _colorCtrl.value),

                      const SizedBox(height: 6),
                      Text(
                        'くるまをこすって あけよう！',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1.5,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Car with bounce
                      Transform.translate(
                        offset: Offset(0, -bounceOffset),
                        child: SizedBox(
                          width: 300,
                          height: 175,
                          child: CustomPaint(
                            painter: CarPainter(config: carCfg),
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Start button
                      _BigStartButton(onTap: widget.onStart),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Rainbow title text ────────────────────────────────────────────────────────
class _RainbowTitle extends StatelessWidget {
  final String text;
  final double size;
  final double t;
  const _RainbowTitle(this.text, this.size, this.t);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: const [
          Color(0xFFFF5555),
          Color(0xFFFFAA00),
          Color(0xFFFFFF00),
          Color(0xFF55FF55),
          Color(0xFF55AAFF),
          Color(0xFFBB55FF),
          Color(0xFFFF55AA),
        ],
        stops: List.generate(7, (i) => ((i / 6) + t * 0.4) % 1.0)
          ..sort(),
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 4,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
        ),
      ),
    );
  }
}

// ── Big pulsing start button ──────────────────────────────────────────────────
class _BigStartButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BigStartButton({required this.onTap});

  @override
  State<_BigStartButton> createState() => _BigStartButtonState();
}

class _BigStartButtonState extends State<_BigStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glow = 0.25 + 0.25 * _ctrl.value;
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.btnAgain,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.btnAgain.withValues(alpha: glow),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Text(
              'はじめる！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Twinkling star background ─────────────────────────────────────────────────
class _StarsBgPainter extends CustomPainter {
  final double t;
  _StarsBgPainter(this.t);

  static final _rng = math.Random(42);
  static final _stars = List.generate(
    60,
    (_) => Offset(_rng.nextDouble(), _rng.nextDouble()),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final twinkle = math.sin(t * math.pi * 2 + i * 0.7) * 0.5 + 0.5;
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        1 + twinkle * 1.5,
        Paint()..color = Colors.white.withValues(alpha: twinkle * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsBgPainter old) => old.t != t;
}
