import 'package:flutter/material.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';

class Themes {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final MonetTheme monetTheme;

  Themes(
    this.lightTheme,
    this.darkTheme,
    this.monetTheme,
  );
}

class MD3ThemeData {
  final MonetTheme colorTheme;
  final MD3TextTheme textTheme;
  final MD3ElevationTheme elevation;
  final MD3StateLayerOpacityTheme stateLayerOpacity;

  const MD3ThemeData({
    required this.colorTheme,
    required this.textTheme,
    required this.elevation,
    required this.stateLayerOpacity,
  });
}

enum MD3WindowSizeClass {
  compact,
  medium,
  expanded,
}

extension MD3WindowSizeClassE on MD3WindowSizeClass {
  int get columns {
    switch (this) {
      case MD3WindowSizeClass.compact:
        return 4;
      case MD3WindowSizeClass.medium:
      case MD3WindowSizeClass.expanded:
        return 12;
    }
  }

  double get minimumMargins {
    switch (this) {
      case MD3WindowSizeClass.compact:
        return 8;
      case MD3WindowSizeClass.medium:
        return 12;
      case MD3WindowSizeClass.expanded:
        return 32;
    }
  }
}
