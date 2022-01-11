import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';

import '../material_you_splash.dart';
import 'button.dart';
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
  elevationTheme ??= MD3ElevationTheme.baseline;
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
  elevationTheme ??= MD3ElevationTheme.baseline;
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
      // Clip because otherwise an highlight leaks on the corners of the
      // PopupMenu container
      clipBehavior: Clip.antiAlias,
    ),
    cardTheme: CardTheme(
      color: elevationTheme.level0.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.all(4.0),
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
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: elevationTheme.level1.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      contentTextStyle: TextStyle(color: scheme.onSurface),
      elevation: elevationTheme.level1.value,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outline,
    ),
    checkboxTheme: _checkboxThemeFor(scheme, stateLayerOpacityTheme),
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
    inputDecorationTheme: InputDecorationTheme(
      fillColor: scheme.surfaceVariant,
      iconColor: scheme.onSurfaceVariant,
      focusColor: Color.alphaBlend(
        scheme.onSurfaceVariant.withOpacity(stateLayerOpacityTheme.focused),
        scheme.surfaceVariant,
      ),
      hoverColor: Color.alphaBlend(
        scheme.onSurfaceVariant.withOpacity(stateLayerOpacityTheme.hovered),
        scheme.surfaceVariant,
      ),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
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
      style: MD3ElevatedButton.defaultStyleFor(
        scheme: scheme,
        textScaleFactor: textScaleFactor,
        textTheme: textTheme,
        stateLayerOpacityTheme: stateLayerOpacityTheme,
        elevationTheme: elevationTheme,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: MD3OutlinedButton.defaultStyleFor(
        scheme: scheme,
        textScaleFactor: textScaleFactor,
        textTheme: textTheme,
        stateLayerOpacityTheme: stateLayerOpacityTheme,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: MD3TextButton.defaultStyleFor(
        scheme: scheme,
        textScaleFactor: textScaleFactor,
        textTheme: textTheme,
        stateLayerOpacityTheme: stateLayerOpacityTheme,
      ),
    ),
  );
}

CheckboxThemeData _checkboxThemeFor(MonetColorScheme scheme,
        MD3StateLayerOpacityTheme stateLayerOpacityTheme) =>
    CheckboxThemeData(
      shape: const CircleBorder(),
      overlayColor: MD3StateOverlayColor(
        MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return scheme.onPrimaryContainer;
          }
          return scheme.onSurface;
        }),
        stateLayerOpacityTheme,
      ),
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          if (states.contains(MaterialState.disabled)) {
            return scheme.onSurface.withOpacity(0.38);
          }
          return scheme.primaryContainer;
        }
        return scheme.onSurfaceVariant;
      }),
      checkColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          if (states.contains(MaterialState.disabled)) {
            return scheme.onSurface.withOpacity(0.38);
          }
          return scheme.onPrimaryContainer;
        }
        return scheme.onSurfaceVariant;
      }),
    );
