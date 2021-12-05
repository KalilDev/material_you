import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_you/material_you.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'dart:math' as math;
import 'package:flutter_monet_theme/flutter_monet_theme.dart';
export 'package:flutter_monet_theme/flutter_monet_theme.dart';
import 'dart:ui' as ui;

import 'material_state.dart';
import 'model.dart';

MonetTheme monetThemeFromPalette(PlatformPalette palette) {
  return generateTheme(
    palette.primaryColor,
  );
}

@Deprecated('Use themesFromPlatform or themesFromMonet')
Themes themesFrom(
  PlatformPalette palette,
) =>
    themesFromPlatform(palette);

Themes themesFromPlatform(
  PlatformPalette palette, {
  MonetTheme? monetThemeForFallbackPalette,
  MD3ElevationTheme? elevationTheme,
  MD3TextTheme? textTheme,
  MD3DeviceType deviceType = MD3DeviceType.mobile,
  double textScaleFactor = 1,
  MD3StateLayerOpacityTheme? stateLayerOpacityTheme,
}) {
  elevationTheme ??= baselineMD3Elevation;
  stateLayerOpacityTheme ??= MD3StateLayerOpacityTheme.baseline;
  MonetTheme monet;
  if (palette.source != PaletteSource.platform) {
    monet = monetThemeForFallbackPalette ?? monetThemeFromPalette(palette);
  } else {
    monet = monetThemeFromPalette(palette);
  }
  textTheme ??= generateTextTheme().resolveTo(deviceType);

  return Themes(
    _themeFrom(
      monet,
      textTheme,
      elevationTheme,
      textScaleFactor,
      deviceType,
      stateLayerOpacityTheme,
      false,
    ),
    _themeFrom(
      monet,
      textTheme,
      elevationTheme,
      textScaleFactor,
      deviceType,
      stateLayerOpacityTheme,
      true,
    ),
    monet,
  );
}

Themes themesFromMonet(
  MonetTheme monet, {
  MD3ElevationTheme? elevationTheme,
  MD3TextTheme? textTheme,
  MD3DeviceType deviceType = MD3DeviceType.mobile,
  double textScaleFactor = 1,
  MD3StateLayerOpacityTheme? stateLayerOpacityTheme,
}) {
  textTheme ??= generateTextTheme().resolveTo(deviceType);
  elevationTheme ??= baselineMD3Elevation;
  stateLayerOpacityTheme ??= MD3StateLayerOpacityTheme.baseline;
  return Themes(
    _themeFrom(
      monet,
      textTheme,
      elevationTheme,
      textScaleFactor,
      deviceType,
      stateLayerOpacityTheme,
      false,
    ),
    _themeFrom(
      monet,
      textTheme,
      elevationTheme,
      textScaleFactor,
      deviceType,
      stateLayerOpacityTheme,
      true,
    ),
    monet,
  );
}

ThemeData _themeFrom(
  MonetTheme monet,
  MD3TextTheme textTheme,
  MD3ElevationTheme elevationTheme,
  double textScaleFactor,
  MD3DeviceType deviceType,
  MD3StateLayerOpacityTheme stateLayerOpacityTheme,
  bool isDark,
) {
  final scheme = isDark ? monet.dark : monet.light;

  AlignmentGeometry? dialogAlignment;
  if (deviceType == MD3DeviceType.tablet) {
    // Positioned to the right for an more ergonomic experience.
    // This is only an aproximation! An proper MD3 dialog layout is required for
    // the spec behavior.
    // https://m3.material.io/m3/pages/dialogs/guidelines/#9d723c7a-03d1-4e7c-95af-a20ed4b66533
    dialogAlignment = AlignmentDirectional(ui.lerpDouble(-1, 1, 3 / 4)!, 0);
  }
  return ThemeData.from(
    colorScheme: scheme.toColorScheme(),
    textTheme: textTheme.toTextTheme(),
  ).copyWith(
    appBarTheme: AppBarTheme(
      // level0: fixed
      // level2: onScroll
      backgroundColor: elevationTheme.level0.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      foregroundColor: scheme.onSurface,
      titleTextStyle: textTheme.titleLarge.copyWith(
        color: scheme.onSurface,
      ),
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 0,
      // level1: modal
      // level0: standard
      backgroundColor: elevationTheme.level1.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
    ),
    splashFactory: MaterialYouInkSplash.splashFactory,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: scheme.background,
    splashColor: Colors.black.withAlpha(40),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: elevationTheme.level3.overlaidColor(
        scheme.primaryContainer,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      foregroundColor: scheme.onPrimaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: elevationTheme.level2.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: MaterialStateProperty.all(textTheme.labelMedium),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: elevationTheme.level0.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      elevation: 0.0,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: elevationTheme.level3.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      contentTextStyle: textTheme.bodyMedium.copyWith(
        color: scheme.onSurface,
      ),
      titleTextStyle: textTheme.headlineSmall.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: dialogAlignment,
    ),
    // TODO
    popupMenuTheme: PopupMenuThemeData(
      color: elevationTheme.level3.overlaidColor(
        scheme.surfaceVariant,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      textStyle: TextStyle(
        color: scheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    cardTheme: CardTheme(
      color: elevationTheme.level0.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.all(4.0),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    }),
    androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
    iconTheme: IconThemeData(
      color: scheme.onBackground,
    ),
    // TODO:
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceVariant,
    ),
    // TODO:
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: scheme.primaryContainer,
      contentTextStyle: TextStyle(color: scheme.onPrimaryContainer),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
    ),
    navigationRailTheme: NavigationRailThemeData(
      // TODO: check if it uses the surface tint or not
      backgroundColor: elevationTheme.level0.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      elevation: 0.0,
      selectedIconTheme: IconThemeData(
        color: scheme.onSurface,
      ),
      selectedLabelTextStyle: TextStyle(
        color: scheme.onSurface,
      ),
    ),
    // TODO: dayPeriod and input decoration
    timePickerTheme: TimePickerThemeData(
      dialHandColor: scheme.primary,
      // This is not right.
      dialBackgroundColor: elevationTheme.level1.overlaidColor(
        scheme.surfaceVariant,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      dialTextColor: scheme.onSurfaceVariant,
      backgroundColor: elevationTheme.level3.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      entryModeIconColor: scheme.onSurface,
      hourMinuteColor: scheme.primaryContainer,
      hourMinuteTextColor: scheme.onPrimaryContainer,
      dayPeriodColor: scheme.tertiary,
      dayPeriodTextColor: scheme.onTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      // TODO: check if it is 16
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      backgroundColor: scheme.inverseSurface,
      actionTextColor: scheme.inversePrimary,
      disabledActionTextColor: scheme.onInverseSurface.withOpacity(0.38),
      contentTextStyle: TextStyle(
        color: scheme.onInverseSurface,
      ),
    ),
    /*chipTheme: ChipThemeData.fromDefaults(
      secondaryColor: scheme.secondary,
      labelStyle: TextStyle(
        color: scheme.onSecondary,
      ),
      brightness: scheme.secondary.textColor == Colors.white
          ? Brightness.light
          : Brightness.dark,
    ),*/
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle(
        scheme,
        textScaleFactor,
        textTheme,
        elevationTheme,
        stateLayerOpacityTheme,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(
        scheme,
        textScaleFactor,
        textTheme,
        stateLayerOpacityTheme,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle(
        scheme,
        textScaleFactor,
        textTheme,
        stateLayerOpacityTheme,
      ),
    ),
  );
}

ButtonStyle _textButtonStyle(
  MonetColorScheme scheme,
  double textScaleFactor,
  MD3TextTheme textTheme,
  MD3StateLayerOpacityTheme stateLayerOpacity,
) {
  final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
    const EdgeInsets.symmetric(horizontal: 12),
    const EdgeInsets.symmetric(horizontal: 8),
    const EdgeInsets.symmetric(horizontal: 4),
    textScaleFactor,
  );
  return ButtonStyle(
    shape: MaterialStateProperty.all(StadiumBorder()),
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor: MD3DisablableColor(
      scheme.primary,
      disabledColor: scheme.onSurface,
    ),
    overlayColor: MD3StateOverlayColor(scheme.primary, stateLayerOpacity),
    padding: MaterialStateProperty.all(scaledPadding),
    fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
    minimumSize: MaterialStateProperty.all(Size(48, 0)),
    textStyle: MaterialStateProperty.all(textTheme.labelLarge),
    splashFactory: MaterialYouInkSplash.splashFactory,
  );
}

ButtonStyle _elevatedButtonStyle(
  MonetColorScheme scheme,
  double textScaleFactor,
  MD3TextTheme textTheme,
  MD3ElevationTheme elevation,
  MD3StateLayerOpacityTheme stateLayerOpacity,
) {
  final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
    const EdgeInsets.symmetric(horizontal: 24),
    const EdgeInsets.symmetric(horizontal: 16),
    const EdgeInsets.symmetric(horizontal: 8),
    textScaleFactor,
  );
  return ButtonStyle(
    shape: MaterialStateProperty.all(StadiumBorder()),
    backgroundColor: _DefaultElevatedButtonBackgroundColor(scheme, elevation),
    foregroundColor:
        MD3DisablableColor(scheme.primary, disabledColor: scheme.onSurface),
    overlayColor: MD3StateOverlayColor(scheme.primary, stateLayerOpacity),
    elevation: _DefaultElevatedButtonElevation(elevation),
    padding: MaterialStateProperty.all(scaledPadding),
    fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
    textStyle: MaterialStateProperty.all(textTheme.labelLarge),
    splashFactory: MaterialYouInkSplash.splashFactory,
  );
}

ButtonStyle _outlinedButtonStyle(
  MonetColorScheme scheme,
  double textScaleFactor,
  MD3TextTheme textTheme,
  MD3StateLayerOpacityTheme stateLayerOpacity,
) {
  final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
    const EdgeInsets.symmetric(horizontal: 24),
    const EdgeInsets.symmetric(horizontal: 16),
    const EdgeInsets.symmetric(horizontal: 8),
    textScaleFactor,
  );
  return ButtonStyle(
    shape: _DefaultOutlinedButtonShape(scheme),
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor: MD3DisablableColor(
      scheme.primary,
      disabledColor: scheme.onSurface,
    ),
    overlayColor: MD3StateOverlayColor(scheme.primary, stateLayerOpacity),
    padding: MaterialStateProperty.all(scaledPadding),
    fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
    textStyle: MaterialStateProperty.all(textTheme.labelLarge),
    splashFactory: MaterialYouInkSplash.splashFactory,
  );
}

@immutable
class _DefaultOutlinedButtonShape
    extends MaterialStateProperty<OutlinedBorder> {
  _DefaultOutlinedButtonShape(this.scheme);

  final MonetColorScheme scheme;

  @override
  OutlinedBorder resolve(Set<MaterialState> states) {
    double width = 1;
    Color color = scheme.outline;
    if (states.contains(MaterialState.focused)) {
      color = scheme.primary;
    }
    if (states.contains(MaterialState.disabled)) {
      color = scheme.outline.withOpacity(0.12);
    }
    return StadiumBorder(side: BorderSide(color: color, width: width));
  }
}

@immutable
class _DefaultElevatedButtonElevation extends MaterialStateProperty<double> {
  _DefaultElevatedButtonElevation(this.elevation);

  final MD3ElevationTheme elevation;

  @override
  double resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return elevation.level0.value;
    }
    if (states.contains(MaterialState.hovered)) {
      return elevation.level2.value;
    }
    return elevation.level1.value;
  }
}

@immutable
class _DefaultElevatedButtonBackgroundColor
    extends MaterialStateProperty<Color> {
  _DefaultElevatedButtonBackgroundColor(this.scheme, this.elevation);

  final MonetColorScheme scheme;
  final MD3ElevationTheme elevation;

  @override
  Color resolve(Set<MaterialState> states) {
    Color color = scheme.surface;
    if (states.contains(MaterialState.disabled)) {
      color = scheme.onSurface;
    }
    Color tint = MD3ElevationLevel.surfaceTint(scheme);
    MD3ElevationLevel level = elevation.level1;
    if (states.contains(MaterialState.disabled)) {
      level = elevation.level0;
      color = color.withOpacity(0.12);
    } else if (states.contains(MaterialState.hovered)) {
      level = elevation.level2;
    }
    return level.overlaidColor(color, tint);
  }
}
