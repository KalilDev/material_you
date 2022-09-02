import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:dynamic_color_compat/dynamic_color_compat.dart';
import '../single_cache.dart';
import 'animated.dart';
import 'generation.dart';
import 'inherited.dart';
import 'model.dart';

extension MD3DeviceInfoContextE on BuildContext {
  MD3WindowSizeClass get sizeClass =>
      _InheritedMD3DeviceInfo.of(this).sizeClass;
  MD3DeviceType get deviceType => _InheritedMD3DeviceInfo.of(this).deviceType;

  double get minMargin => sizeClass.minimumMargins;
  int get columns => sizeClass.columns;
}

typedef MD3ThemedBuilder = Widget Function(
  BuildContext,
  ThemeData light,
  ThemeData dark,
);

// An opaque object which, when == to another [_TextThemeIdentity], determines
// if the [MD3TextTheme]s are equal. This is an temporary workaround while it
// doesn't override the equality operator.
@immutable
class _TextThemeIdentity {
  // Used to resolve
  final MD3DeviceType deviceType;
  // Will be checked by identity.
  final MD3TextAdaptativeTheme? userTextThemeOrNull;

  const _TextThemeIdentity(this.deviceType, this.userTextThemeOrNull);
  @override
  int get hashCode => Object.hashAll([
        deviceType,
        identityHashCode(userTextThemeOrNull),
      ]);

  @override
  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! _TextThemeIdentity) {
      return false;
    }
    return other.deviceType == deviceType &&
        identical(other.userTextThemeOrNull, userTextThemeOrNull);
  }
}

// The operator == on [CorePalette] is broken (https://github.com/material-foundation/material-color-utilities/issues/56)
// therefore we need to use an identity.
class _CorePaletteIdentity {
  final CorePalette corePalette;

  _CorePaletteIdentity(this.corePalette);
  static int tonalPaletteHash(TonalPalette p) => Object.hashAll(p.asList);
  static bool tonalPaletteEq(TonalPalette a, TonalPalette b) {
    final aList = a.asList;
    final bList = b.asList;
    for (var i = 0; i < TonalPalette.commonSize; i++) {
      if (aList[i] != bList[i]) {
        return false;
      }
    }
    return true;
  }

  int get hashCode => Object.hashAll([
        tonalPaletteHash(corePalette.primary),
        tonalPaletteHash(corePalette.secondary),
        tonalPaletteHash(corePalette.tertiary),
        tonalPaletteHash(corePalette.neutral),
        tonalPaletteHash(corePalette.neutralVariant),
        tonalPaletteHash(corePalette.error),
      ]);
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! _CorePaletteIdentity) {
      return false;
    }
    return tonalPaletteEq(corePalette.primary, other.corePalette.primary) &&
        tonalPaletteEq(corePalette.secondary, other.corePalette.secondary) &&
        tonalPaletteEq(corePalette.tertiary, other.corePalette.tertiary) &&
        tonalPaletteEq(corePalette.neutral, other.corePalette.neutral) &&
        tonalPaletteEq(
            corePalette.neutralVariant, other.corePalette.neutralVariant) &&
        tonalPaletteEq(corePalette.error, other.corePalette.error);
  }
}

class _PlatformPaletteThemesIdentity {
  // Used by the monet themes
  // When the platform returned an fallback and the user provided an fallback
  // palette, this is null. Otherwise it is the seed.
  final Color? seedOrNull;

  // When the platform returned an fallback and the user provided an fallback
  // palette, this is not null. Otherwise it is null.
  // Will be checked by identity.
  final MonetTheme? fallbackThemeOrNull;

  const _PlatformPaletteThemesIdentity({
    required this.seedOrNull,
    required this.fallbackThemeOrNull,
  });
  @override
  int get hashCode => Object.hashAll([
        seedOrNull,
        identityHashCode(fallbackThemeOrNull),
      ]);

  @override
  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! _PlatformPaletteThemesIdentity) {
      return false;
    }
    return other.seedOrNull == seedOrNull &&
        identical(other.fallbackThemeOrNull, fallbackThemeOrNull);
  }
}

// An opaque object which, when == to another themesIdentity, determines if
// the monet themes are equal. This is an temporary workaround while they
// don't override the equality operator.
@immutable
class _ThemesIdentity {
  // Used by text themes and for the dialog positioning
  final MD3DeviceType deviceType;
  // Used by button and the text themes.
  final double textScaleFactor;
  // Will be checked by identity.
  final MD3ElevationTheme? userElevationThemeOrNull;
  // Will be checked by identity.
  final MD3TextAdaptativeTheme? userTextThemeOrNull;
  // Either a [CorePalette] or an [_PlatformPaletteThemesIdentity]
  final Object themeIdentity;

  const _ThemesIdentity({
    required this.deviceType,
    required this.textScaleFactor,
    required this.userElevationThemeOrNull,
    required this.userTextThemeOrNull,
    required this.themeIdentity,
  });

  @override
  int get hashCode => Object.hashAll([
        deviceType,
        textScaleFactor,
        identityHashCode(userElevationThemeOrNull),
        identityHashCode(userTextThemeOrNull),
        themeIdentity
      ]);

  @override
  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! _ThemesIdentity) {
      return false;
    }
    return other.deviceType == deviceType &&
        textScaleFactor == other.textScaleFactor &&
        identical(other.userElevationThemeOrNull, userElevationThemeOrNull) &&
        identical(other.userTextThemeOrNull, userTextThemeOrNull) &&
        other.themeIdentity == themeIdentity;
  }
}

typedef MD3Themes = MD3ThemedApp<NoAppScheme, NoAppTheme>;

class MD3ThemedApp<S extends AppCustomColorScheme<S>,
    T extends AppCustomColorTheme<S, T>> extends StatefulWidget {
  const MD3ThemedApp({
    Key? key,
    this.mediaQueryData,
    this.targetPlatform,
    @Deprecated("use useDynamicColor and corePalette") this.seed,
    @Deprecated("use useDynamicColor and corePalette")
        this.monetThemeForFallbackPalette,
    this.textTheme,
    this.elevationTheme,
    this.stateLayerOpacityTheme,
    this.appThemeFactory,
    this.animated = true,
    @Deprecated("use useDynamicColor and corePalette")
        this.usePlatformPalette = true,
    this.useDynamicColor = true,
    this.corePalette,
    required this.builder,
  })  : assert(seed == null ||
            monetThemeForFallbackPalette == null ||
            corePalette != null ||
            useDynamicColor),
        assert(usePlatformPalette ||
            monetThemeForFallbackPalette != null ||
            useDynamicColor),
        super(key: key);
  final MediaQueryData? mediaQueryData;
  final TargetPlatform? targetPlatform;
  @Deprecated("use useDynamicColor and corePalette")
  final Color? seed;
  @Deprecated("use useDynamicColor and corePalette")
  final MonetTheme? monetThemeForFallbackPalette;
  final MD3TextAdaptativeTheme? textTheme;
  final MD3ElevationTheme? elevationTheme;
  final MD3StateLayerOpacityTheme? stateLayerOpacityTheme;
  final T Function(MonetTheme)? appThemeFactory;
  final bool animated;
  final MD3ThemedBuilder builder;
  @Deprecated("use useDynamicColor and corePalette")
  final bool usePlatformPalette;
  final bool useDynamicColor;
  final CorePalette? corePalette;

  static const _kDesktopPlatforms = {
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
  };

  @override
  State<MD3ThemedApp<S, T>> createState() => _MD3ThemedAppState<S, T>();
}

class _AppThemeIdentity {
  final _ThemesIdentity themesIdentity;
  final Function? appThemeFactory;

  const _AppThemeIdentity({
    required this.themesIdentity,
    required this.appThemeFactory,
  });

  @override
  int get hashCode => Object.hashAll([
        themesIdentity,
        appThemeFactory,
      ]);

  @override
  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! _AppThemeIdentity) {
      return false;
    }
    return other.themesIdentity == themesIdentity &&
        other.appThemeFactory == appThemeFactory;
  }
}

class _MD3ThemedAppState<S extends AppCustomColorScheme<S>,
        T extends AppCustomColorTheme<S, T>> extends State<MD3ThemedApp<S, T>>
    with WidgetsBindingObserver {
  final _cache = SingleCache<_ThemesIdentity, Themes>();
  final _appThemeCache = SingleCache<_AppThemeIdentity, T?>();
  final _textThemeCache = SingleCache<_TextThemeIdentity, MD3TextTheme>();
  final _childKey = GlobalKey();
  // Register as an WidgetsBindingObserver so we are notified of metrics
  // changes.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = widget.mediaQueryData ??
        MediaQuery.maybeOf(context) ??
        MediaQueryData.fromWindow(ui.window);
    final targetPlatform = widget.targetPlatform ?? defaultTargetPlatform;
    final willUseDynamicColor = widget.useDynamicColor &&
            context.dependOnInheritedWidgetOfExactType<
                    InheritedDynamicColor>() !=
                null ||
        widget.corePalette != null;
    final palette = !willUseDynamicColor && widget.usePlatformPalette
        ? context.palette
        : null;
    final elevationTheme = widget.elevationTheme ?? MD3ElevationTheme.baseline;
    final stateLayerOpacity =
        widget.stateLayerOpacityTheme ?? MD3StateLayerOpacityTheme.baseline;

    final MD3DeviceType deviceType;
    if (MD3ThemedApp._kDesktopPlatforms.contains(targetPlatform)) {
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

    final willUseFallbackOnPlatformPalette =
        widget.monetThemeForFallbackPalette != null &&
            widget.seed == null &&
            palette?.source != PaletteSource.platform;
    final seedForPlatformPalette = widget.seed ??
        (widget.usePlatformPalette && !willUseDynamicColor
            ? palette!.primaryColor
            : null);
    final Object themeIdentity;
    if (willUseDynamicColor) {
      themeIdentity = _CorePaletteIdentity(widget.corePalette != null
          ? widget.corePalette!
          : context.dynamicColor);
    } else {
      final seed = widget.seed ??
          (widget.usePlatformPalette ? palette!.primaryColor : null);
      themeIdentity = _PlatformPaletteThemesIdentity(
        seedOrNull: willUseFallbackOnPlatformPalette ? null : seed,
        fallbackThemeOrNull: willUseFallbackOnPlatformPalette
            ? widget.monetThemeForFallbackPalette
            : null,
      );
    }

    final textScaleFactor = mediaQuery.textScaleFactor;

    final identity = _ThemesIdentity(
      deviceType: deviceType,
      textScaleFactor: textScaleFactor,
      userElevationThemeOrNull: widget.elevationTheme,
      userTextThemeOrNull: widget.textTheme,
      themeIdentity: themeIdentity,
    );

    final textThemeIdentity = _TextThemeIdentity(
      deviceType,
      widget.textTheme,
    );
    // Cache the text theme
    final resolvedTextTheme = _textThemeCache.putIfAbsent(
      textThemeIdentity,
      () {
        final textTheme = widget.textTheme ?? generateTextTheme();
        return textTheme.resolveTo(deviceType);
      },
    );
    // Cache the themes generated from the seed values
    final themes = _cache.putIfAbsent(
      identity,
      () {
        if (willUseDynamicColor) {
          return themesFromCorePalette(
            widget.corePalette ?? context.dynamicColor,
            textTheme: resolvedTextTheme,
            elevationTheme: elevationTheme,
            textScaleFactor: textScaleFactor,
            stateLayerOpacityTheme: stateLayerOpacity,
          );
        }
        return themesFromPlatform(
          seedForPlatformPalette == null
              ? null
              : PlatformPalette.fallback(primaryColor: seedForPlatformPalette),
          monetThemeForFallbackPalette: willUseFallbackOnPlatformPalette
              ? widget.monetThemeForFallbackPalette
              : null,
          textTheme: resolvedTextTheme,
          elevationTheme: elevationTheme,
          textScaleFactor: textScaleFactor,
          stateLayerOpacityTheme: stateLayerOpacity,
        );
      },
    );
    // Cache the app theme generated from the theme
    final appTheme = _appThemeCache.putIfAbsent(
      _AppThemeIdentity(
          themesIdentity: identity, appThemeFactory: widget.appThemeFactory),
      () => widget.appThemeFactory?.call(themes.monetTheme),
    );

    final md3ThemeData = MD3ThemeData(
      colorTheme: themes.monetTheme,
      textTheme: resolvedTextTheme,
      elevation: elevationTheme,
      stateLayerOpacity: stateLayerOpacity,
    );

    final innerBuilder = Builder(
      builder: (context) {
        var child = widget.builder(
          context,
          themes.lightTheme,
          themes.darkTheme,
        );
        child = KeyedSubtree(
          key: _childKey,
          child: child,
        );
        if (appTheme != null) {
          return widget.animated
              ? AnimatedAppCustomColorTheme<S, T>(
                  data: appTheme,
                  child: child,
                )
              : InheritedAppCustomColorTheme<S, T>(
                  data: appTheme,
                  child: child,
                );
        }
        return child;
      },
    );

    return _InheritedMD3DeviceInfo(
      sizeClass: windowSizeClass,
      deviceType: deviceType,
      child: widget.animated
          ? AnimatedMD3Theme(data: md3ThemeData, child: innerBuilder)
          : InheritedMD3Theme(
              data: md3ThemeData,
              child: innerBuilder,
            ),
    );
  }
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
