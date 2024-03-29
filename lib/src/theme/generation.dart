import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:material_you/src/theme.dart';
import 'package:dynamic_color_compat/dynamic_color_compat.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:monet_theme/monet_theme.dart';

import 'button.dart';
import 'model.dart';

MonetTheme monetThemeFromCorePalette(CorePalette palette) {
  return MonetTheme.fromRaw(generateRawThemeFrom(palette));
}

MonetTheme monetThemeFromPalette(PlatformPalette palette) {
  return generateTheme(
    palette.primaryColor,
  );
}

Themes themesFromCorePalette(
  CorePalette palette, {
  MD3ElevationTheme? elevationTheme,
  MD3TextTheme? textTheme,
  MD3DeviceType deviceType = MD3DeviceType.mobile,
  double textScaleFactor = 1,
  MD3StateLayerOpacityTheme? stateLayerOpacityTheme,
}) =>
    themesFromPlatform(
      const PlatformPalette.fallback(primaryColor: Color(0xDEADBEEF)),
      monetThemeForFallbackPalette: monetThemeFromCorePalette(palette),
      elevationTheme: elevationTheme,
      textTheme: textTheme,
      deviceType: deviceType,
      textScaleFactor: textScaleFactor,
      stateLayerOpacityTheme: stateLayerOpacityTheme,
    );

@Deprecated('Use themesFromPlatform or themesFromMonet')
Themes themesFrom(
  PlatformPalette palette,
) =>
    themesFromPlatform(palette);

const themesFromPlatform = themesFromPlatformPalette;

Themes themesFromPlatformPalette(
  PlatformPalette? palette, {
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
  if (palette?.source != PaletteSource.platform) {
    monet = monetThemeForFallbackPalette ?? monetThemeFromPalette(palette!);
  } else {
    monet = monetThemeFromPalette(palette!);
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
    useMaterial3: true,
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
    splashFactory: InkRipple.splashFactory,
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
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            color: scheme.onSecondaryContainer,
            opacity: 1,
          );
        }
        return IconThemeData(
          color: scheme.onSurfaceVariant,
          opacity: 1,
        );
      }),
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        final style = textTheme.labelMedium;
        if (states.contains(MaterialState.selected)) {
          return style.copyWith(color: scheme.onSurface);
        }
        return style.copyWith(color: scheme.onSurfaceVariant);
      }),
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
    // TODO:
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: scheme.onSurface,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: scheme.primary,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: elevationTheme.level0.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      elevation: elevationTheme.level0.value,
      selectedIconTheme: IconThemeData(
        color: scheme.onSurface,
      ),
      selectedLabelTextStyle: textTheme.labelMedium.copyWith(
        color: scheme.onSurface,
      ),
      unselectedIconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium.copyWith(
        color: scheme.onSurfaceVariant,
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
      dialTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? scheme.onSurface
              : scheme.onPrimary),
      backgroundColor: elevationTheme.level3.overlaidColor(
        scheme.surface,
        MD3ElevationLevel.surfaceTint(scheme),
      ),
      entryModeIconColor: scheme.onSurface,
      hourMinuteColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? scheme.primaryContainer
              : scheme.surfaceVariant),
      hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? scheme.onPrimaryContainer
              : scheme.onSurface),
      dayPeriodColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? scheme.tertiary
              : scheme.surfaceVariant),
      dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? scheme.onTertiary
              : scheme.onSurface),
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
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      // TODO: find tooltip textStyle
      textStyle: textTheme.labelSmall.copyWith(
        color: scheme.onInverseSurface,
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
