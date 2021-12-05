import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'dart:math' as math;
import 'package:flutter_monet_theme/flutter_monet_theme.dart';
export 'package:flutter_monet_theme/flutter_monet_theme.dart';
import 'dart:ui' as ui;

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

// An opaque object which, when == to another themesIdentity, determines if
// the monet themes are equal. This is an temporary workaround while they
// don't override the equality operator.
@immutable
class _ThemesIdentity {
  // Used by the monet themes
  // When the platform returned an fallback and the user provided an fallback
  // palette, this is null. Otherwise it is the seed.
  final Color? seedOrNull;
  // Used by text themes and for the dialog positioning
  final MD3DeviceType deviceType;
  // Used by button and the text themes.
  final double textScaleFactor;
  // When the platform returned an fallback and the user provided an fallback
  // palette, this is not null. Otherwise it is null.
  // Will be checked by identity.
  final MonetTheme? fallbackThemeOrNull;
  // Will be checked by identity.
  final MD3ElevationTheme? userElevationThemeOrNull;
  // Will be checked by identity.
  final MD3TextAdaptativeTheme? userTextThemeOrNull;

  const _ThemesIdentity({
    required this.seedOrNull,
    required this.deviceType,
    required this.textScaleFactor,
    required this.fallbackThemeOrNull,
    required this.userElevationThemeOrNull,
    required this.userTextThemeOrNull,
  });

  @override
  int get hashCode => Object.hashAll([
        seedOrNull,
        deviceType,
        textScaleFactor,
        identityHashCode(fallbackThemeOrNull),
        identityHashCode(userElevationThemeOrNull),
        identityHashCode(userTextThemeOrNull),
      ]);

  @override
  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! _ThemesIdentity) {
      return false;
    }
    return other.seedOrNull == seedOrNull &&
        other.deviceType == deviceType &&
        textScaleFactor == other.textScaleFactor &&
        identical(other.fallbackThemeOrNull, fallbackThemeOrNull) &&
        identical(other.userElevationThemeOrNull, userElevationThemeOrNull) &&
        identical(other.userTextThemeOrNull, userTextThemeOrNull);
  }
}

typedef MD3Themes = MD3ThemedApp<NoAppScheme, NoAppTheme>;

class MD3ThemedApp<S extends AppCustomColorScheme<S>,
    T extends AppCustomColorTheme<S, T>> extends StatefulWidget {
  const MD3ThemedApp({
    Key? key,
    this.mediaQueryData,
    this.targetPlatform,
    this.seed,
    this.monetThemeForFallbackPalette,
    this.textTheme,
    this.elevationTheme,
    this.stateLayerOpacityTheme,
    this.appThemeFactory,
    this.animated = true,
    required this.builder,
  })  : assert(seed == null || monetThemeForFallbackPalette == null),
        super(key: key);
  final MediaQueryData? mediaQueryData;
  final TargetPlatform? targetPlatform;
  final Color? seed;
  final MonetTheme? monetThemeForFallbackPalette;
  final MD3TextAdaptativeTheme? textTheme;
  final MD3ElevationTheme? elevationTheme;
  final MD3StateLayerOpacityTheme? stateLayerOpacityTheme;
  final T Function(MonetTheme)? appThemeFactory;
  final bool animated;
  final MD3ThemedBuilder builder;

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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = widget.mediaQueryData ??
        MediaQuery.maybeOf(context) ??
        MediaQueryData.fromWindow(ui.window);
    final targetPlatform = widget.targetPlatform ?? defaultTargetPlatform;
    final palette = context.palette;
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

    final willUseFallback = widget.monetThemeForFallbackPalette != null &&
        widget.seed == null &&
        palette.source != PaletteSource.platform;
    final seed = widget.seed ?? palette.primaryColor;
    final textScaleFactor = mediaQuery.textScaleFactor;

    final identity = _ThemesIdentity(
      seedOrNull: willUseFallback ? null : seed,
      deviceType: deviceType,
      textScaleFactor: textScaleFactor,
      fallbackThemeOrNull:
          willUseFallback ? widget.monetThemeForFallbackPalette : null,
      userElevationThemeOrNull: widget.elevationTheme,
      userTextThemeOrNull: widget.textTheme,
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
      () => themesFromPlatform(
        PlatformPalette.fallback(primaryColor: seed),
        monetThemeForFallbackPalette:
            willUseFallback ? widget.monetThemeForFallbackPalette : null,
        textTheme: resolvedTextTheme,
        elevationTheme: elevationTheme,
        textScaleFactor: textScaleFactor,
        stateLayerOpacityTheme: stateLayerOpacity,
      ),
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
