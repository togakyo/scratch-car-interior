import 'package:flutter/material.dart';
import 'models/car_config.dart';
import 'screens/play_screen.dart';
import 'screens/scratch_screen.dart';
import 'screens/title_screen.dart';

void main() => runApp(const ScratchCarApp());

class ScratchCarApp extends StatelessWidget {
  const ScratchCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCRATCH CAR！',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9B44FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const _AppRoot(),
    );
  }
}

enum _Screen { title, scratch, play }

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  _Screen _screen = _Screen.title;
  late CarConfig _carConfig;

  @override
  void initState() {
    super.initState();
    _carConfig = CarConfig.random();
  }

  void _startGame() {
    setState(() {
      _carConfig = CarConfig.random();
      _screen = _Screen.scratch;
    });
  }

  void _onScratchComplete() {
    setState(() => _screen = _Screen.play);
  }

  void _playAgain() {
    setState(() {
      _carConfig = CarConfig.random();
      _screen = _Screen.scratch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: switch (_screen) {
        _Screen.title => TitleScreen(
            key: const ValueKey('title'),
            onStart: _startGame,
          ),
        _Screen.scratch => ScratchScreen(
            key: const ValueKey('scratch'),
            carConfig: _carConfig,
            onComplete: _onScratchComplete,
          ),
        _Screen.play => PlayScreen(
            key: const ValueKey('play'),
            carConfig: _carConfig,
            onPlayAgain: _playAgain,
          ),
      },
    );
  }
}
