import 'package:flutter/material.dart';

import '../material_you_splash.dart';
import 'inherited.dart';
import 'material_state.dart';
import 'model.dart';

abstract class MD3ElevatedButton {
  static ButtonStyle styleFrom({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color disabledColor,
    required MD3StateLayerOpacityTheme stateLayerOpacityTheme,
    required MaterialStateProperty<MD3ElevationLevel> md3Elevation,
    Color? shadowColor,
    TextStyle? labelStyle,
    MouseCursor? disabledCursor,
    MouseCursor? enabledCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    InteractiveInkFeatureFactory? splashFactory,
    OutlinedBorder? shape,
  }) {
    ArgumentError.checkNotNull(backgroundColor);
    ArgumentError.checkNotNull(foregroundColor);
    ArgumentError.checkNotNull(disabledColor);
    ArgumentError.checkNotNull(stateLayerOpacityTheme);
    ArgumentError.checkNotNull(md3Elevation);

    return ButtonStyle(
      shape: ButtonStyleButton.allOrNull(shape),
      backgroundColor: MD3DisablableColor(
        MD3ElevationTintableColor(
          backgroundColor,
          foregroundColor,
          md3Elevation,
        ),
        disabledOpacity: 0.12,
        disabledColor: disabledColor,
      ),
      foregroundColor: MD3DisablableColor(
        foregroundColor,
        disabledColor: disabledColor,
      ),
      overlayColor: MD3StateOverlayColor(
        foregroundColor,
        stateLayerOpacityTheme,
      ),
      padding:
          MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
      fixedSize: MaterialStateProperty.all(const Size.fromHeight(40)),
      minimumSize: MaterialStateProperty.all(const Size(48, 0)),
      maximumSize: MaterialStateProperty.all(Size.infinite),
      textStyle: ButtonStyleButton.allOrNull(labelStyle),
      shadowColor: ButtonStyleButton.allOrNull(shadowColor),
      elevation: md3Elevation.value,
      tapTargetSize: tapTargetSize,
      visualDensity: visualDensity,
      mouseCursor: MD3DisablableCursor(
        enabledCursor ?? SystemMouseCursors.click,
        disabledCursor ?? SystemMouseCursors.forbidden,
      ),
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: splashFactory,
    );
  }

  static ButtonStyle defaultStyleFor({
    required MonetColorScheme scheme,
    required double textScaleFactor,
    required MD3TextTheme textTheme,
    required MD3ElevationTheme elevationTheme,
    required MD3StateLayerOpacityTheme stateLayerOpacityTheme,
  }) =>
      styleFrom(
        stateLayerOpacityTheme: stateLayerOpacityTheme,
        labelStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
        disabledColor: scheme.onSurface,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.primary,
        splashFactory: MaterialYouInkSplash.splashFactory,
        md3Elevation: MD3MaterialStateElevation(
          elevationTheme.level1,
          elevationTheme.level2,
          disabled: elevationTheme.level0,
        ),
      ).copyWith(
        padding: MaterialStateProperty.all(
          ButtonStyleButton.scaledPadding(
            const EdgeInsets.symmetric(horizontal: 24),
            const EdgeInsets.symmetric(horizontal: 16),
            const EdgeInsets.symmetric(horizontal: 8),
            textScaleFactor,
          ),
        ),
      );

  static ButtonStyle defaultStyleOf(BuildContext context) => defaultStyleFor(
        scheme: context.colorScheme,
        textScaleFactor: MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        textTheme: context.textTheme,
        stateLayerOpacityTheme: context.stateOverlayOpacity,
        elevationTheme: context.elevation,
      );

  static ButtonStyle? themeStyleOf(BuildContext context) =>
      ElevatedButtonTheme.of(context).style;
}

abstract class MD3OutlinedButton {
  static ButtonStyle styleFrom({
    required Color foregroundColor,
    required Color disabledColor,
    required Color outlineColor,
    required MD3StateLayerOpacityTheme stateLayerOpacityTheme,
    Color? shadowColor,
    MaterialStateProperty<MD3ElevationLevel>? md3Elevation,
    TextStyle? labelStyle,
    MouseCursor? disabledCursor,
    MouseCursor? enabledCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    InteractiveInkFeatureFactory? splashFactory,
    OutlinedBorder? shape,
  }) {
    ArgumentError.checkNotNull(foregroundColor);
    ArgumentError.checkNotNull(disabledColor);
    ArgumentError.checkNotNull(stateLayerOpacityTheme);

    return ButtonStyle(
      shape: ButtonStyleButton.allOrNull(shape),
      side: _DefaultMD3OutlinedButtonBorderSide(
        outline: outlineColor,
        primary: foregroundColor,
      ),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MD3DisablableColor(
        foregroundColor,
        disabledColor: disabledColor,
      ),
      overlayColor:
          MD3StateOverlayColor(foregroundColor, stateLayerOpacityTheme),
      padding:
          MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
      fixedSize: MaterialStateProperty.all(const Size.fromHeight(40)),
      minimumSize: MaterialStateProperty.all(const Size(48, 0)),
      maximumSize: MaterialStateProperty.all(Size.infinite),
      textStyle: ButtonStyleButton.allOrNull(labelStyle),
      shadowColor: ButtonStyleButton.allOrNull(shadowColor),
      elevation: md3Elevation?.value,
      tapTargetSize: tapTargetSize,
      visualDensity: visualDensity,
      mouseCursor: MD3DisablableCursor(
        enabledCursor ?? SystemMouseCursors.click,
        disabledCursor ?? SystemMouseCursors.forbidden,
      ),
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: splashFactory,
    );
  }

  static ButtonStyle defaultStyleFor({
    required MonetColorScheme scheme,
    required double textScaleFactor,
    required MD3TextTheme textTheme,
    required MD3StateLayerOpacityTheme stateLayerOpacityTheme,
  }) =>
      styleFrom(
        stateLayerOpacityTheme: stateLayerOpacityTheme,
        labelStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
        disabledColor: scheme.onSurface,
        foregroundColor: scheme.primary,
        outlineColor: scheme.outline,
        splashFactory: MaterialYouInkSplash.splashFactory,
      ).copyWith(
        padding: MaterialStateProperty.all(
          ButtonStyleButton.scaledPadding(
            const EdgeInsets.symmetric(horizontal: 24),
            const EdgeInsets.symmetric(horizontal: 16),
            const EdgeInsets.symmetric(horizontal: 8),
            textScaleFactor,
          ),
        ),
      );

  static ButtonStyle defaultStyleOf(BuildContext context) => defaultStyleFor(
        scheme: context.colorScheme,
        textScaleFactor: MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        textTheme: context.textTheme,
        stateLayerOpacityTheme: context.stateOverlayOpacity,
      );

  static ButtonStyle? themeStyleOf(BuildContext context) =>
      OutlinedButtonTheme.of(context).style;
}

abstract class MD3TextButton {
  static ButtonStyle styleFrom({
    required Color foregroundColor,
    required Color disabledColor,
    required MD3StateLayerOpacityTheme stateLayerOpacityTheme,
    Color? shadowColor,
    MaterialStateProperty<MD3ElevationLevel>? md3Elevation,
    TextStyle? labelStyle,
    MouseCursor? disabledCursor,
    MouseCursor? enabledCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    InteractiveInkFeatureFactory? splashFactory,
    OutlinedBorder? shape,
  }) {
    ArgumentError.checkNotNull(foregroundColor);
    ArgumentError.checkNotNull(disabledColor);
    ArgumentError.checkNotNull(stateLayerOpacityTheme);

    return ButtonStyle(
      shape: ButtonStyleButton.allOrNull(shape),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MD3DisablableColor(
        foregroundColor,
        disabledColor: disabledColor,
      ),
      overlayColor:
          MD3StateOverlayColor(foregroundColor, stateLayerOpacityTheme),
      padding:
          MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
      fixedSize: MaterialStateProperty.all(const Size.fromHeight(40)),
      minimumSize: MaterialStateProperty.all(const Size(48, 0)),
      maximumSize: MaterialStateProperty.all(Size.infinite),
      textStyle: ButtonStyleButton.allOrNull(labelStyle),
      shadowColor: ButtonStyleButton.allOrNull(shadowColor),
      elevation: md3Elevation?.value,
      tapTargetSize: tapTargetSize,
      visualDensity: visualDensity,
      mouseCursor: MD3DisablableCursor(
        enabledCursor ?? SystemMouseCursors.click,
        disabledCursor ?? SystemMouseCursors.forbidden,
      ),
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: splashFactory,
    );
  }

  static ButtonStyle defaultStyleFor({
    required MonetColorScheme scheme,
    required double textScaleFactor,
    required MD3TextTheme textTheme,
    required MD3StateLayerOpacityTheme stateLayerOpacityTheme,
  }) =>
      styleFrom(
        stateLayerOpacityTheme: stateLayerOpacityTheme,
        labelStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
        disabledColor: scheme.onSurface,
        foregroundColor: scheme.primary,
        splashFactory: MaterialYouInkSplash.splashFactory,
      ).copyWith(
        padding: MaterialStateProperty.all(
          ButtonStyleButton.scaledPadding(
            const EdgeInsets.symmetric(horizontal: 12),
            const EdgeInsets.symmetric(horizontal: 8),
            const EdgeInsets.symmetric(horizontal: 4),
            textScaleFactor,
          ),
        ),
      );

  static ButtonStyle defaultStyleOf(BuildContext context) => defaultStyleFor(
        scheme: context.colorScheme,
        textScaleFactor: MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        textTheme: context.textTheme,
        stateLayerOpacityTheme: context.stateOverlayOpacity,
      );

  static ButtonStyle? themeStyleOf(BuildContext context) =>
      TextButtonTheme.of(context).style;
}

@immutable
class _DefaultMD3OutlinedButtonBorderSide
    extends MaterialStateProperty<BorderSide> {
  _DefaultMD3OutlinedButtonBorderSide({
    required this.outline,
    required this.primary,
    this.width = 1,
  });

  final Color outline;
  final Color primary;
  final double width;

  @override
  BorderSide resolve(Set<MaterialState> states) {
    states = materialStatesWithImplicits(states);
    Color color = outline;
    if (states.contains(MaterialState.disabled)) {
      color = outline.withOpacity(0.12);
    } else if (states.contains(MaterialState.focused)) {
      color = primary;
    }
    return BorderSide(color: color, width: width);
  }
}
