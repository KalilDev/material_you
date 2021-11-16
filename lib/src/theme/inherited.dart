import 'package:flutter/material.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';

import 'model.dart';

extension MD3ContextE on BuildContext {
  MD3ThemeData get md3Theme => InheritedMD3Theme.of(this);
  MonetTheme get monetTheme =>
      InheritedMonetTheme.maybeOf(this) ?? md3Theme.colorTheme;

  MonetColorScheme get colorScheme =>
      InheritedMonetColorScheme.maybeOf(this) ??
      (isDark ? monetTheme.dark : monetTheme.light);

  MD3TextTheme get textTheme =>
      InheritedMD3TextTheme.maybeOf(this) ?? md3Theme.textTheme;
  MD3ElevationTheme get elevation =>
      InheritedMD3ElevationTheme.maybeOf(this) ?? md3Theme.elevation;
  MD3StateLayerOpacityTheme get stateOverlayOpacity =>
      InheritedMD3StateOverlayOpacityTheme.maybeOf(this) ??
      md3Theme.stateLayerOpacity;
}

extension MaterialContextE on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorSchemeFlt => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
}

class InheritedMD3StateOverlayOpacityTheme extends InheritedWidget {
  final MD3StateLayerOpacityTheme theme;

  const InheritedMD3StateOverlayOpacityTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMD3StateOverlayOpacityTheme oldWidget) =>
      theme != oldWidget.theme;

  static MD3StateLayerOpacityTheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<
          InheritedMD3StateOverlayOpacityTheme>()
      ?.theme;
}

class InheritedMonetColorScheme extends InheritedWidget {
  final MonetColorScheme scheme;

  const InheritedMonetColorScheme({
    Key? key,
    required this.scheme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMonetColorScheme oldWidget) =>
      scheme != oldWidget.scheme;

  static MonetColorScheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedMonetColorScheme>()
      ?.scheme;
}

class InheritedMD3Theme extends InheritedWidget {
  final MD3ThemeData data;

  const InheritedMD3Theme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMD3Theme oldWidget) =>
      data != oldWidget.data;

  static MD3ThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedMD3Theme>()!.data;
}

class InheritedMD3ElevationTheme extends InheritedWidget {
  final MD3ElevationTheme theme;

  const InheritedMD3ElevationTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMD3ElevationTheme oldWidget) =>
      theme != oldWidget.theme;

  static MD3ElevationTheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedMD3ElevationTheme>()
      ?.theme;
}

class InheritedMD3TextTheme extends InheritedWidget {
  final MD3TextTheme theme;

  const InheritedMD3TextTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMD3TextTheme oldWidget) =>
      theme != oldWidget.theme;

  static MD3TextTheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedMD3TextTheme>()
      ?.theme;
}

class InheritedMonetTheme extends InheritedWidget {
  final MonetTheme theme;

  const InheritedMonetTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMonetTheme oldWidget) =>
      theme != oldWidget.theme;

  static MonetTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedMonetTheme>()?.theme;
}
