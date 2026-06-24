import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/sound_manager.dart';
import '../models/car_config.dart';
import '../painters/car_painter.dart';
import '../painters/confetti_painter.dart';
import '../painters/scratch_painter.dart';
import '../theme/app_colors.dart';

class ScratchScreen extends StatefulWidget {
  final CarConfig carConfig;
  final VoidCallback onComplete;

  const ScratchScreen({
    super.key,
    required this.carConfig,
    required this.onComplete,
  });

  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen>
    with TickerProviderStateMixin {
  // Scratch data
  final List<Offset> _scratchPoints = [];
  final Set<int> _coveredCells = {};
  double _progress = 0;
  bool _completed = false;

  // Progress ring animation
  late AnimationController _progressCtrl;

  // Celebration (confetti + zoom-out of cover)
  late AnimationController _celebCtrl;
  late Animation<double> _coverFade;
  late Animation<double> _carScale;
  final List<ConfettiParticle> _confetti = [];
  final _rng = math.Random();

  // Sparkles following finger
  final List<SparkleParticle> _sparkles = [];
  late AnimationController _sparkleCtrl;
  DateTime _lastScratchTime = DateTime.now();

  // Grid constants for coverage
  static const _gw = 36;
  static const _gh = 24;
  // Brush radius in logical pixels (scaled with screen)
  double _brushRadius = 26;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _celebCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _coverFade = CurvedAnimation(parent: _celebCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 0.0));
    _carScale = CurvedAnimation(parent: _celebCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 1.0, end: 1.12));
    _celebCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onComplete();
    });

    _sparkleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_tickSparkles)
      ..repeat();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _celebCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  // ── Scratch handling ──────────────────────────────────────────────────────

  void _onPan(DragUpdateDetails d, BoxConstraints constraints) {
    if (_completed) return;
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final p = d.localPosition;

    // Adaptive brush radius based on screen size
    _brushRadius = size.shortestSide * 0.065;

    setState(() {
      _scratchPoints.add(p);
      _addSparkle(p, size);
      _updateCoverage(p, size);
    });

    // Throttle sound to avoid spam
    final now = DateTime.now();
    if (now.difference(_lastScratchTime).inMilliseconds > 60) {
      SoundManager.scratch();
      _lastScratchTime = now;
    }

    if (_progress >= 0.68 && !_completed) {
      _triggerReveal();
    }
  }

  void _updateCoverage(Offset p, Size size) {
    final gx = (p.dx / size.width * _gw).round().clamp(0, _gw - 1);
    final gy = (p.dy / size.height * _gh).round().clamp(0, _gh - 1);
    final cells = (_brushRadius / size.width * _gw).ceil() + 1;
    for (var dx = -cells; dx <= cells; dx++) {
      for (var dy = -cells; dy <= cells; dy++) {
        final nx = (gx + dx).clamp(0, _gw - 1);
        final ny = (gy + dy).clamp(0, _gh - 1);
        _coveredCells.add(ny * _gw + nx);
      }
    }
    _progress = _coveredCells.length / (_gw * _gh);
  }

  void _addSparkle(Offset pos, Size size) {
    if (_sparkles.length > 60) _sparkles.removeRange(0, 10);
    for (var i = 0; i < 3; i++) {
      _sparkles.add(SparkleParticle(
        pos: pos + Offset((_rng.nextDouble() - 0.5) * 24, (_rng.nextDouble() - 0.5) * 24),
        color: AppColors.sparkles[_rng.nextInt(AppColors.sparkles.length)],
        radius: 5 + _rng.nextDouble() * 7,
      ));
    }
  }

  void _tickSparkles() {
    const dt = 0.016;
    setState(() {
      for (final s in _sparkles) s.update(dt);
      _sparkles.removeWhere((s) => s.life <= 0);

      if (_completed) {
        for (final c in _confetti) c.update(dt);
        _confetti.removeWhere((c) => c.life <= 0);
      }
    });
  }

  void _triggerReveal() {
    _completed = true;
    SoundManager.reveal();

    // Spawn confetti
    for (var i = 0; i < 80; i++) {
      _confetti.add(ConfettiParticle.spawn(
        // Use approximate screen size; will be close enough
        const Size(400, 700),
        _rng,
      ));
    }

    _celebCtrl.forward();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        child: SafeArea(
          child: LayoutBuilder(builder: (ctx, constraints) {
            return Column(
              children: [
                const SizedBox(height: 12),
                // Progress row
                _buildProgressRow(),
                const SizedBox(height: 8),
                // Scratch area
                Expanded(
                  child: Center(
                    child: _buildScratchArea(constraints),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProgressRow() {
    final pct = (_progress * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress.clamp(0, 1),
                minHeight: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(const Color(0xFF00AAFF), const Color(0xFFFFDD00),
                      _progress)!,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScratchArea(BoxConstraints outer) {
    final maxW = outer.maxWidth * 0.95;
    final maxH = outer.maxHeight * 0.80;
    final w = math.min(maxW, maxH * (480 / 280));
    final h = w * (280 / 480);

    return AnimatedBuilder(
      animation: Listenable.merge([_celebCtrl]),
      builder: (_, __) {
        return Transform.scale(
          scale: _completed ? _carScale.value : 1.0,
          child: SizedBox(
            width: w,
            height: h,
            child: LayoutBuilder(builder: (_, c) {
              return GestureDetector(
                onPanUpdate: _completed
                    ? null
                    : (d) => _onPan(d, c),
                child: Stack(
                  children: [
                    // 1. Car (bottom layer)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CarPainter(config: widget.carConfig),
                      ),
                    ),

                    // 2. Scratch overlay (fades out on reveal)
                    Positioned.fill(
                      child: Opacity(
                        opacity: _completed ? _coverFade.value : 1.0,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: ScratchPainter(
                              points: _scratchPoints,
                              brushRadius: _brushRadius,
                              seed: widget.carConfig.dirtSeed,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Sparkles
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SparklePainter(_sparkles),
                      ),
                    ),

                    // 4. Confetti (after reveal)
                    if (_completed)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ConfettiPainter(_confetti),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
