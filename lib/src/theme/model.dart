import 'package:flutter/material.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';

abstract class NoAppScheme extends AppCustomColorScheme<NoAppScheme> {}

abstract class NoAppTheme extends AppCustomColorTheme<NoAppScheme, NoAppTheme> {
}

abstract class AppCustomColorScheme<Self> {
  const AppCustomColorScheme();
  Self lerpWith(Self b, double t);
}

abstract class AppCustomColorTheme<S extends AppCustomColorScheme<S>,
    Self extends AppCustomColorTheme<S, Self>> {
  const AppCustomColorTheme();
  S get light;
  S get dark;
  Self lerpWith(Self b, double t);
}

class Themes {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final MonetTheme monetTheme;

  Themes(
    this.lightTheme,
    this.darkTheme,
    this.monetTheme,
  );

  int get hashCode => Object.hashAll([
        lightTheme,
        darkTheme,
        monetTheme,
      ]);

  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! Themes) {
      return false;
    }
    return true &&
        lightTheme == other.lightTheme &&
        darkTheme == other.darkTheme &&
        monetTheme == other.monetTheme;
  }
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

  int get hashCode => Object.hashAll([
        colorTheme,
        textTheme,
        elevation,
        stateLayerOpacity,
      ]);

  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! MD3ThemeData) {
      return false;
    }
    return true &&
        colorTheme == other.colorTheme &&
        elevation == other.elevation &&
        stateLayerOpacity == other.stateLayerOpacity;
  }

  MD3ThemeData copyWith({
    MonetTheme? colorTheme,
    MD3TextTheme? textTheme,
    MD3ElevationTheme? elevation,
    MD3StateLayerOpacityTheme? stateLayerOpacity,
  }) =>
      MD3ThemeData(
        colorTheme: colorTheme ?? this.colorTheme,
        textTheme: textTheme ?? this.textTheme,
        elevation: elevation ?? this.elevation,
        stateLayerOpacity: stateLayerOpacity ?? this.stateLayerOpacity,
      );

  static MD3ThemeData lerp(MD3ThemeData a, MD3ThemeData b, double t) {
    assert(a != null);
    assert(b != null);
    assert(t != null);
    return MD3ThemeData(
      colorTheme: MonetTheme.lerp(a.colorTheme, b.colorTheme, t),
      textTheme: MD3TextTheme.lerp(a.textTheme, b.textTheme, t),
      elevation: MD3ElevationTheme.lerp(a.elevation, b.elevation, t),
      stateLayerOpacity: MD3StateLayerOpacityTheme.lerp(
          a.stateLayerOpacity, b.stateLayerOpacity, t),
    );
  }
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
