import 'package:flutter/material.dart';
import 'package:flutter_material_palette/flutter_material_palette.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'dart:math' as math;
import 'material_you_splash.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';

extension MonetContextE on BuildContext {
  @Deprecated('use monetTheme instead!')
  MaterialYouColors get materialYouColors =>
      InheritedMaterialYouColors.of(this);

  MonetTheme get monetTheme => InheritedMonetTheme.of(this);
  MonetColorScheme get colorScheme =>
      isDark ? monetTheme.dark : monetTheme.dark;
  TextTheme get textTheme => theme.textTheme;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorSchemeFlt => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
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
  TextTheme? textTheme,
}) {
  final materialYou = materialYouColorsFromPalette(palette);
  MonetTheme monet;
  if (palette.source == PaletteSource.platform) {
    monet = monetThemeForFallbackPalette ?? monetThemeFromPalette(palette);
  } else {
    monet = monetThemeFromPalette(palette);
  }
  textTheme ??= generateTextTheme();

  return Themes(
    _themeFrom(monet, textTheme, false),
    _themeFrom(monet, textTheme, true),
    materialYou,
    monet,
  );
}

Themes themesFromMonet(
  MonetTheme monet, {
  MaterialYouColors? materialYou,
  TextTheme? textTheme,
}) {
  textTheme ??= generateTextTheme();
  materialYou ??= MaterialYouColors.deriveFrom(monet.primary.getTone(40), null);
  return Themes(
    _themeFrom(monet, textTheme, false),
    _themeFrom(monet, textTheme, true),
    materialYou,
    monet,
  );
}

ThemeData _themeFrom(MonetTheme monet, TextTheme textTheme, bool isDark) {
  final scheme = isDark ? monet.dark : monet.light;

  return ThemeData.from(
    colorScheme: scheme.toColorScheme(),
    textTheme: textTheme,
  ).copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 0,
      backgroundColor: scheme.surface,
    ),
    splashFactory: MaterialYouInkSplash.splashFactory,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: scheme.background,
    splashColor: Colors.black.withAlpha(40),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      selectedItemColor: scheme.surface,
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: scheme.surface,
      elevation: 0.0,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: scheme.surface,
      contentTextStyle: TextStyle(
        color: scheme.onSurface,
      ),
      titleTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    // TODO
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceVariant,
      textStyle: TextStyle(
        color: scheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    cardTheme: CardTheme(
      color: scheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.all(4.0),
    ),
    tooltipTheme: null, // Didnt change!
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
    androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
    iconTheme: IconThemeData(
      color: scheme.onBackground,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceVariant,
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: scheme.primaryContainer,
      contentTextStyle: TextStyle(color: scheme.onPrimaryContainer),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
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
      dialBackgroundColor: scheme.surfaceVariant,
      dialTextColor: scheme.onSurfaceVariant,
      backgroundColor: scheme.surface,
      entryModeIconColor: scheme.onSurface,
      hourMinuteColor: scheme.primaryContainer,
      hourMinuteTextColor: scheme.onPrimaryContainer,
      dayPeriodColor: scheme.tertiary,
      dayPeriodTextColor: scheme.onTertiary,
      /*inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.primary,
      ),*/
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
      backgroundColor: scheme.surfaceVariant,
      contentTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
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
  );
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
