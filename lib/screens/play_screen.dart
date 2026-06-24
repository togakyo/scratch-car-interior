import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/sound_manager.dart';
import '../models/car_config.dart';
import '../painters/car_painter.dart';
import '../painters/confetti_painter.dart';
import '../theme/app_colors.dart';

class PlayScreen extends StatefulWidget {
  final CarConfig carConfig;
  final VoidCallback onPlayAgain;

  const PlayScreen({
    super.key,
    required this.carConfig,
    required this.onPlayAgain,
  });

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen>
    with TickerProviderStateMixin {
  PlayAnim _currentAnim = PlayAnim.none;
  late AnimationController _animCtrl;
  late AnimationController _sparkleCtrl;
  late AnimationController _entryCtrl;

  final List<ConfettiParticle> _confetti = [];
  final _rng = math.Random();
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(vsync: this);
    _animCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _currentAnim = PlayAnim.none;
          _busy = false;
        });
      }
    });

    _sparkleCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
          ..addListener(_tick)
          ..repeat();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _sparkleCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _tick() {
    const dt = 0.016;
    setState(() {
      for (final c in _confetti) c.update(dt);
      _confetti.removeWhere((c) => c.life <= 0);
    });
  }

  void _trigger(PlayAnim anim, double durationSec) {
    if (_busy) return;
    _busy = true;
    setState(() => _currentAnim = anim);
    _animCtrl.duration = Duration(milliseconds: (durationSec * 1000).round());
    _animCtrl.forward(from: 0);

    switch (anim) {
      case PlayAnim.horn: SoundManager.horn(); break;
      case PlayAnim.lights: SoundManager.lights(); break;
      case PlayAnim.wash: SoundManager.wash(); break;
      case PlayAnim.spin: SoundManager.spin(); break;
      case PlayAnim.color: SoundManager.color(); break;
      default: break;
    }
  }

  void _triggerParty() {
    if (_busy) return;
    SoundManager.party();
    for (var i = 0; i < 90; i++) {
      _confetti.add(ConfettiParticle.spawn(
          MediaQuery.sizeOf(context), _rng));
    }
    // Short anim just to show confetti
    _busy = true;
    setState(() => _currentAnim = PlayAnim.none);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _busy = false);
    });
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
          child: AnimatedBuilder(
            animation: Listenable.merge([_animCtrl, _entryCtrl]),
            builder: (ctx, _) {
              return Stack(
                children: [
                  // Main layout
                  _buildLayout(ctx),
                  // Confetti overlay
                  if (_confetti.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                          painter: ConfettiPainter(_confetti)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext ctx) {
    return LayoutBuilder(builder: (_, constraints) {
      final isWide = constraints.maxWidth > 600;
      if (isWide) return _buildWide(constraints);
      return _buildNarrow(constraints);
    });
  }

  // ── Portrait layout ───────────────────────────────────────────────────────

  Widget _buildNarrow(BoxConstraints c) {
    final carH = c.maxHeight * 0.36;
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildLabel(),
        const SizedBox(height: 6),
        // Car
        SizedBox(
          height: carH,
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                      parent: _entryCtrl, curve: Curves.elasticOut)
                  .drive(Tween(begin: 0.6, end: 1.0)),
              child: _buildCar(),
            ),
          ),
        ),
        // Button grid 3×2
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildButtonGrid(),
          ),
        ),
        // Play Again
        _buildPlayAgainBtn(),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Landscape layout ──────────────────────────────────────────────────────

  Widget _buildWide(BoxConstraints c) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLabel(),
              const SizedBox(height: 12),
              Expanded(child: Center(child: _buildCar())),
              _buildPlayAgainBtn(),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildButtonGrid(),
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildLabel() {
    return Text(
      'ボタンをおしてあそぼう！',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white.withValues(alpha: 0.9),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCar() {
    return AspectRatio(
      aspectRatio: 480 / 280,
      child: CustomPaint(
        painter: CarPainter(
          config: widget.carConfig,
          anim: _currentAnim,
          animVal: _animCtrl.value,
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    final buttons = [
      _BtnData('📯', 'プップー', AppColors.btnHorn,
          () => _trigger(PlayAnim.horn, 0.7)),
      _BtnData('💡', 'ライト', AppColors.btnLight,
          () => _trigger(PlayAnim.lights, 1.0)),
      _BtnData('🚿', 'せんしゃ', AppColors.btnWash,
          () => _trigger(PlayAnim.wash, 1.4)),
      _BtnData('🎉', 'パーティ', AppColors.btnParty, _triggerParty),
      _BtnData('🌀', 'くるくる', AppColors.btnSpin,
          () => _trigger(PlayAnim.spin, 1.0)),
      _BtnData('🌈', 'いろかえ', AppColors.btnColor,
          () => _trigger(PlayAnim.color, 1.2)),
    ];

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: buttons.map((b) => _PlayButton(data: b, busy: _busy)).toList(),
    );
  }

  Widget _buildPlayAgainBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: GestureDetector(
        onTap: widget.onPlayAgain,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.btnAgain,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                  color: AppColors.btnAgain.withValues(alpha: 0.4),
                  blurRadius: 12)
            ],
          ),
          child: const Text(
            'もういっかい！ 🎁',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Button data ───────────────────────────────────────────────────────────────

class _BtnData {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BtnData(this.icon, this.label, this.color, this.onTap);
}

// ── Individual play button ────────────────────────────────────────────────────

class _PlayButton extends StatefulWidget {
  final _BtnData data;
  final bool busy;
  const _PlayButton({required this.data, required this.busy});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.busy;
    final c = widget.data.color;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glow = enabled ? (0.2 + 0.15 * _ctrl.value) : 0.0;
        return GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled
              ? (_) {
                  setState(() => _pressed = false);
                  widget.data.onTap();
                }
              : null,
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.91 : 1.0,
            duration: const Duration(milliseconds: 70),
            child: Container(
              decoration: BoxDecoration(
                color: c.withValues(alpha: enabled ? 0.22 : 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: c.withValues(alpha: enabled ? 0.85 : 0.25),
                    width: 2.5),
                boxShadow: enabled
                    ? [BoxShadow(color: c.withValues(alpha: glow), blurRadius: 16)]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.data.icon,
                      style: TextStyle(
                          fontSize: 30,
                          color: enabled ? null : Colors.white30)),
                  const SizedBox(height: 4),
                  Text(
                    widget.data.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: enabled ? Colors.white : Colors.white30,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
