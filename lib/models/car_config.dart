import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CarConfig {
  final Color bodyColor;
  final int dirtSeed; // determines the random-looking gift wrap pattern

  const CarConfig({required this.bodyColor, required this.dirtSeed});

  static CarConfig random() {
    final rng = Random();
    return CarConfig(
      bodyColor: AppColors.carColors[rng.nextInt(AppColors.carColors.length)],
      dirtSeed: rng.nextInt(0x7FFFFFFF),
    );
  }

  // Slightly darker shade for roof / inner panels
  Color get roofColor {
    final hsl = HSLColor.fromColor(bodyColor);
    return hsl.withLightness((hsl.lightness * 0.82).clamp(0, 1)).toColor();
  }

  // Bright highlight tint
  Color get highlightColor {
    final hsl = HSLColor.fromColor(bodyColor);
    return hsl.withLightness((hsl.lightness * 1.25).clamp(0, 1)).toColor();
  }
}
