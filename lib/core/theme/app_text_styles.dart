import 'package:flutter/material.dart';

/// Semantic type scale used across screens.
///
/// Screens pick a role (`section`, `caption`, ...) and only override color, so
/// hierarchy stays consistent instead of every widget choosing its own size
/// and weight. The smallest role is 11px; nothing in the app should go below.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle section = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle metric = TextStyle(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w800,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
