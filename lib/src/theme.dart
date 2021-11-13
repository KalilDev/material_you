import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_palette/flutter_material_palette.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'dart:math' as math;
import 'material_you_splash.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';
export 'package:flutter_monet_theme/flutter_monet_theme.dart';
import 'dart:ui' as ui;

extension MonetContextE on BuildContext {
  @Deprecated('use monetTheme instead!')
  MaterialYouColors get materialYouColors =>
      InheritedMaterialYouColors.of(this);

  MonetTheme get monetTheme => InheritedMonetTheme.of(this);
  MonetColorScheme get colorScheme =>
      isDark ? monetTheme.dark : monetTheme.light;
  MD3TextTheme get textTheme => _InheritedMD3TextTheme.of(this);
  MD3WindowSizeClass get sizeClass =>
      _InheritedMD3DeviceInfo.of(this).sizeClass;
  MD3DeviceType get deviceType => _InheritedMD3DeviceInfo.of(this).deviceType;
  double get minMargin => sizeClass.minimumMargins;
  int get columns => sizeClass.columns;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorSchemeFlt => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
  MD3ElevationTheme get elevation => _InheritedMD3ElevationTheme.of(this);
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

class MD3Themes extends StatefulWidget {
  const MD3Themes({
    Key? key,
    this.mediaQueryData,
    this.targetPlatform,
    this.monetThemeForFallbackPalette,
    this.textTheme,
    this.elevationTheme,
    required this.builder,
  }) : super(key: key);
  final MediaQueryData? mediaQueryData;
  final TargetPlatform? targetPlatform;
  final MonetTheme? monetThemeForFallbackPalette;
  final MD3TextAdaptativeTheme? textTheme;
  final MD3ElevationTheme? elevationTheme;
  final Widget Function(BuildContext, ThemeData light, ThemeData dark) builder;

  static const _kDesktopPlatforms = {
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
  };

  @override
  State<MD3Themes> createState() => _MD3ThemesState();
}

class _MD3ThemesState extends State<MD3Themes> with WidgetsBindingObserver {
  // Register as an WidgetsBindingObserver so we are notified of metrics
  // changes.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // The MediaQueryData.fromWindow has changed!
    setState(() {});
  }

  @override
  void didChangeTextScaleFactor() {
    // The MediaQueryData.fromWindow has changed!
    setState(() {});
  }

  ThemeData _resolveThemeFor(BuildContext context, ThemeData theme) {
    final deviceType = context.deviceType;
    final sizeClass = context.sizeClass;
    var dialogAlignment = theme.dialogTheme.alignment ?? Alignment.center;
    if (deviceType == MD3DeviceType.tablet) {
      // Positioned to the right for an more ergonomic experience.
      // https://m3.material.io/m3/pages/dialogs/guidelines/#9d723c7a-03d1-4e7c-95af-a20ed4b66533
      dialogAlignment = AlignmentDirectional(ui.lerpDouble(-1, 1, 3 / 4)!, 0);
    }
    return theme.copyWith(
        dialogTheme: theme.dialogTheme.copyWith(
      alignment: dialogAlignment,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = widget.mediaQueryData ??
        MediaQuery.maybeOf(context) ??
        MediaQueryData.fromWindow(ui.window);
    final targetPlatform = widget.targetPlatform ?? defaultTargetPlatform;
    final palette = context.palette;
    final elevationTheme = widget.elevationTheme ?? baselineMD3Elevation;
    final textTheme = widget.textTheme ?? generateTextTheme();

    final MD3DeviceType deviceType;
    if (MD3Themes._kDesktopPlatforms.contains(targetPlatform)) {
      deviceType = MD3DeviceType.desktop;
    } else if (mediaQuery.size.longestSide <= 180) {
      // Estimate smaller than 180 devices to be watches
      deviceType = MD3DeviceType.watch;
    } else if (mediaQuery.size.longestSide >= 1200) {
      // Estimate larger than 1200 devices to be TVs
      deviceType = MD3DeviceType.largeScreenTv;
    } else {
      final isPortrait = mediaQuery.orientation == Orientation.portrait;
      final width = mediaQuery.size.width;
      if (width >= 0 && width < 600) {
        deviceType = isPortrait ? MD3DeviceType.mobile : MD3DeviceType.mobile;
      } else if (width >= 600 && width < 840) {
        deviceType = isPortrait ? MD3DeviceType.tablet : MD3DeviceType.tablet;
      } else {
        deviceType = isPortrait ? MD3DeviceType.tablet : MD3DeviceType.tablet;
      }
    }
    final MD3WindowSizeClass windowSizeClass;
    final width = mediaQuery.size.width;
    if (width >= 0 && width < 600) {
      windowSizeClass = MD3WindowSizeClass.compact;
    } else if (width >= 600 && width < 840) {
      windowSizeClass = MD3WindowSizeClass.medium;
    } else {
      windowSizeClass = MD3WindowSizeClass.expanded;
    }
    final resolvedTextTheme = textTheme.resolveTo(deviceType);

    final themes = themesFromPlatform(
      palette,
      monetThemeForFallbackPalette: widget.monetThemeForFallbackPalette,
      textTheme: resolvedTextTheme,
      elevationTheme: elevationTheme,
      textScaleFactor: mediaQuery.textScaleFactor,
    );
    return _InheritedMD3TextTheme(
      theme: resolvedTextTheme,
      child: InheritedMonetTheme(
        theme: themes.monetTheme,
        child: _InheritedMD3DeviceInfo(
          sizeClass: windowSizeClass,
          deviceType: deviceType,
          child: _InheritedMD3ElevationTheme(
            theme: elevationTheme,
            child: Builder(
              builder: (context) => widget.builder(
                context,
                _resolveThemeFor(context, themes.lightTheme),
                _resolveThemeFor(context, themes.darkTheme),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InheritedMD3ElevationTheme extends InheritedWidget {
  final MD3ElevationTheme theme;

  const _InheritedMD3ElevationTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_InheritedMD3ElevationTheme oldWidget) =>
      theme != oldWidget.theme;

  static MD3ElevationTheme of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedMD3ElevationTheme>()!
      .theme;
}

class _InheritedMD3DeviceInfo extends InheritedWidget {
  final MD3WindowSizeClass sizeClass;
  final MD3DeviceType deviceType;

  const _InheritedMD3DeviceInfo({
    Key? key,
    required this.sizeClass,
    required this.deviceType,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_InheritedMD3DeviceInfo oldWidget) =>
      sizeClass != oldWidget.sizeClass || deviceType != oldWidget.deviceType;

  static _InheritedMD3DeviceInfo of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedMD3DeviceInfo>()!;
}

class _InheritedMD3TextTheme extends InheritedWidget {
  final MD3TextTheme theme;

  const _InheritedMD3TextTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_InheritedMD3TextTheme oldWidget) =>
      theme != oldWidget.theme;

  static MD3TextTheme of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedMD3TextTheme>()!
      .theme;
}

@Deprecated('Use MD3Themes')
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

  static MonetTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedMonetTheme>()!.theme;
}

@Deprecated('Use InheritedMonetTheme')
class InheritedMaterialYouColors extends InheritedWidget {
  final MaterialYouColors colors;

  const InheritedMaterialYouColors({
    Key? key,
    required this.colors,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(InheritedMaterialYouColors oldWidget) =>
      colors != oldWidget.colors;

  static MaterialYouColors of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedMaterialYouColors>()!
      .colors;
}

class Themes {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final MaterialYouColors materialYouColors;
  final MonetTheme monetTheme;

  Themes(
    this.lightTheme,
    this.darkTheme,
    this.materialYouColors,
    this.monetTheme,
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
  double textScaleFactor = 1,
}) {
  final materialYou = materialYouColorsFromPalette(palette);

  elevationTheme ??= baselineMD3Elevation;
  MonetTheme monet;
  if (palette.source != PaletteSource.platform) {
    monet = monetThemeForFallbackPalette ?? monetThemeFromPalette(palette);
  } else {
    monet = monetThemeFromPalette(palette);
  }
  textTheme ??= generateTextTheme().resolveTo(MD3DeviceType.mobile);

  return Themes(
    _themeFrom(monet, textTheme, elevationTheme, textScaleFactor, false),
    _themeFrom(monet, textTheme, elevationTheme, textScaleFactor, true),
    materialYou,
    monet,
  );
}

Themes themesFromMonet(
  MonetTheme monet, {
  MaterialYouColors? materialYou,
  MD3ElevationTheme? elevationTheme,
  MD3TextTheme? textTheme,
  double textScaleFactor = 1,
}) {
  textTheme ??= generateTextTheme().resolveTo(MD3DeviceType.mobile);
  materialYou ??= MaterialYouColors.deriveFrom(monet.primary.getTone(40), null);
  elevationTheme ??= baselineMD3Elevation;
  return Themes(
    _themeFrom(monet, textTheme, elevationTheme, textScaleFactor, false),
    _themeFrom(monet, textTheme, elevationTheme, textScaleFactor, true),
    materialYou,
    monet,
  );
}

ThemeData _themeFrom(
  MonetTheme monet,
  MD3TextTheme textTheme,
  MD3ElevationTheme elevationTheme,
  double textScaleFactor,
  bool isDark,
) {
  final scheme = isDark ? monet.dark : monet.light;

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

    /* This component is not used in material3
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      selectedItemColor: scheme.surface,
    ),*/
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
        scheme.surfaceVariant,
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
      contentTextStyle: TextStyle(
        color: scheme.inverseOnSurface,
      ),
    ),
    chipTheme: ChipThemeData.fromDefaults(
      secondaryColor: scheme.secondary,
      labelStyle: TextStyle(
        color: scheme.onSecondary,
      ),
      brightness: scheme.secondary.textColor == Colors.white
          ? Brightness.light
          : Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle(
        scheme,
        textScaleFactor,
        textTheme,
        elevationTheme,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(
        scheme,
        textScaleFactor,
        textTheme,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle(
        scheme,
        textScaleFactor,
        textTheme,
      ),
    ),
  );
}

ButtonStyle _textButtonStyle(
  MonetColorScheme scheme,
  double textScaleFactor,
  MD3TextTheme textTheme,
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
    foregroundColor: _DefaultTextButtonForegroundColor(scheme),
    overlayColor: _DefaultTextButtonOverlayColor(scheme),
    padding: MaterialStateProperty.all(scaledPadding),
    fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
    minimumSize: MaterialStateProperty.all(Size(48, 0)),
    textStyle: MaterialStateProperty.all(textTheme.labelLarge),
  );
}

ButtonStyle _elevatedButtonStyle(
  MonetColorScheme scheme,
  double textScaleFactor,
  MD3TextTheme textTheme,
  MD3ElevationTheme elevation,
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
    foregroundColor: _DefaultElevatedButtonForegroundColor(scheme),
    overlayColor: _DefaultElevatedButtonOverlayColor(scheme),
    elevation: _DefaultElevatedButtonElevation(elevation),
    padding: MaterialStateProperty.all(scaledPadding),
    fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
    textStyle: MaterialStateProperty.all(textTheme.labelLarge),
  );
}

ButtonStyle _outlinedButtonStyle(
  MonetColorScheme scheme,
  double textScaleFactor,
  MD3TextTheme textTheme,
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
    foregroundColor: _DefaultOutlinedButtonForegroundColor(scheme),
    overlayColor: _DefaultOutlinedButtonOverlayColor(scheme),
    padding: MaterialStateProperty.all(scaledPadding),
    fixedSize: MaterialStateProperty.all(Size.fromHeight(40)),
    textStyle: MaterialStateProperty.all(textTheme.labelLarge),
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
    }
    if (states.contains(MaterialState.hovered)) {
      level = elevation.level2;
    }
    return level.overlaidColor(color, tint);
  }
}

@immutable
class _DefaultElevatedButtonForegroundColor
    extends MaterialStateProperty<Color> {
  _DefaultElevatedButtonForegroundColor(this.scheme);

  final MonetColorScheme scheme;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return scheme.onSurface.withOpacity(0.38);
    }
    return scheme.primary;
  }
}

@immutable
class _DefaultElevatedButtonOverlayColor extends MaterialStateProperty<Color> {
  _DefaultElevatedButtonOverlayColor(this.scheme);

  final MonetColorScheme scheme;

  @override
  Color resolve(Set<MaterialState> states) {
    final color = scheme.primary;
    if (states.contains(MaterialState.hovered)) {
      return color.withOpacity(0.08);
    }
    if (states.contains(MaterialState.focused)) {
      return color.withOpacity(0.24);
    }
    if (states.contains(MaterialState.pressed)) {
      return color.withOpacity(0.24);
    }

    return Colors.transparent;
  }
}

@immutable
class _DefaultTextButtonForegroundColor extends MaterialStateProperty<Color> {
  _DefaultTextButtonForegroundColor(this.scheme);

  final MonetColorScheme scheme;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return scheme.onSurface.withOpacity(0.38);
    }
    return scheme.primary;
  }
}

@immutable
class _DefaultTextButtonOverlayColor extends MaterialStateProperty<Color> {
  _DefaultTextButtonOverlayColor(this.scheme);

  final MonetColorScheme scheme;

  @override
  Color resolve(Set<MaterialState> states) {
    final color = scheme.primary;
    if (states.contains(MaterialState.hovered)) {
      return color.withOpacity(0.08);
    }
    if (states.contains(MaterialState.focused)) {
      return color.withOpacity(0.24);
    }
    if (states.contains(MaterialState.pressed)) {
      return color.withOpacity(0.24);
    }

    return Colors.transparent;
  }
}

@immutable
class _DefaultOutlinedButtonForegroundColor
    extends MaterialStateProperty<Color> {
  _DefaultOutlinedButtonForegroundColor(this.scheme);

  final MonetColorScheme scheme;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return scheme.onSurface.withOpacity(0.38);
    }
    return scheme.primary;
  }
}

@immutable
class _DefaultOutlinedButtonOverlayColor extends MaterialStateProperty<Color> {
  _DefaultOutlinedButtonOverlayColor(this.scheme);

  final MonetColorScheme scheme;

  @override
  Color resolve(Set<MaterialState> states) {
    final color = scheme.primary;
    if (states.contains(MaterialState.hovered)) {
      return color.withOpacity(0.08);
    }
    if (states.contains(MaterialState.focused)) {
      return color.withOpacity(0.24);
    }
    if (states.contains(MaterialState.pressed)) {
      return color.withOpacity(0.24);
    }

    return Colors.transparent;
  }
}

extension on Color {
  bool get isMonochromatic => (red == green) && (green == blue);
  double get hue {
    if (isMonochromatic) {
      return 0;
    }

    double hue;

    final rgb = _rgbComponents;

    final max = rgb.reduce(math.max);
    final min = rgb.reduce(math.min);
    final difference = max - min;

    if (max == min) {
      hue = 0;
    } else {
      if (max == red) {
        hue = (green - blue) / difference + ((green < blue) ? 6 : 0);
      } else if (max == green) {
        hue = (blue - red) / difference + 2;
      } else {
        hue = (red - green) / difference + 4;
      }

      hue /= 6;
    }

    return hue * 360;
  }

  List<int> get _rgbComponents => [red, green, blue];
}

@Deprecated('Use monetThemeFromPalette')
MaterialYouColors materialYouColorsFromPalette(PlatformPalette palette) {
  final primaryHue = palette.primaryColor.hue;
  Color? maybeUse(Color? color) {
    if (color == null) {
      return null;
    }
    final deltaHue = (color.hue - primaryHue).abs();
    const harmonicColors = [-30, 30, 60, 120, 180];
    if (harmonicColors.any((c) => deltaHue > c - 5 && deltaHue < c + 5)) {
      return color;
    }
  }

  final secondary =
      maybeUse(palette.secondaryColor) ?? maybeUse(palette.tertiaryColor);

  return MaterialYouColors.deriveFrom(palette.primaryColor, secondary);
}

MonetTheme monetThemeFromPalette(PlatformPalette palette) {
  return generateTheme(
    palette.primaryColor,
  );
}

const kDesaturatedSwatch = 200;

extension TextColorDerivation on Color {
  Color get textColor {
    final contrastRatioBlack =
        (computeLuminance() + 0.05) / (Colors.black.computeLuminance() + 0.05);
    final contrastRatioWhite =
        (Colors.white.computeLuminance() + 0.05) / (computeLuminance() + 0.05);
    return contrastRatioBlack > contrastRatioWhite
        ? Colors.black
        : Colors.white;
  }
}
