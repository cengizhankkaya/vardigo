import 'package:flutter/material.dart';

import 'pill_tabs.dart';

/// Colors and sizes of one [PillTabs] design; each screen has its own.
class PillTabsStyle {
  const PillTabsStyle({
    required this.background,
    required this.radius,
    required this.pillRadius,
    required this.pillPadding,
    required this.activeColor,
    required this.activeShadow,
    required this.textStyle,
    required this.activeTextColor,
    required this.inactiveTextColor,
    this.gap = 0,
  });

  final Color background;
  final double radius;
  final double pillRadius;
  final EdgeInsets pillPadding;
  final Color activeColor;
  final List<BoxShadow> activeShadow;
  final TextStyle textStyle;
  final Color activeTextColor;
  final Color inactiveTextColor;

  /// Space between pills.
  final double gap;
}
