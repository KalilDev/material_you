import 'package:flutter/material.dart';
import 'package:flutter_material_palette/flutter_material_palette.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'dart:math' as math;
import 'material_you_splash.dart';

extension MaterialYouContextE on BuildContext {
  MaterialYouColors get materialYouColors =>
      InheritedMaterialYouColors.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
}

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

  Themes(this.lightTheme, this.darkTheme, this.materialYouColors);
}

Themes themesFrom(PlatformPalette palette) {
  final materialYou = materialYouColorsFromPalette(palette);
  return Themes(
    _themeFrom(
        materialYou, colorSchemeFromMaterialYouColors(materialYou, false)),
    _themeFrom(
        materialYou, colorSchemeFromMaterialYouColors(materialYou, true)),
    materialYou,
  );
}

ThemeData _themeFrom(MaterialYouColors materialYou, ColorScheme scheme) {
  final brightness = scheme.brightness;
  final isDark = brightness == Brightness.dark;
  final paintedSurfaceBg = Color.alphaBlend(
    (isDark ? materialYou.accent1.shade100 : materialYou.accent2.shade200)
        .withOpacity(isDark ? 0.10 : 0.33),
    scheme.background,
  );
  final bottomNavBarBg = Color.alphaBlend(
    (isDark ? materialYou.accent2.shade200 : materialYou.accent1.shade100)
        .withOpacity(isDark ? 0.07 : 0.24),
    scheme.background,
  );
  final fabBg = materialYou.accent2[isDark ? 700 : 100]!;
  final paintedSurfaceFgColor =
      isDark ? materialYou.accent2.shade100 : materialYou.accent2.shade900;
  // TODO
  final colorfulSurfaceBg =
      isDark ? materialYou.accent1.shade300 : materialYou.accent1.shade700;
  // TODO
  final colorfulSurfaceFg = colorfulSurfaceBg.textColor;
  return ThemeData.from(colorScheme: scheme).copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: paintedSurfaceBg,
      foregroundColor: paintedSurfaceFgColor,
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      elevation: 0,
      backgroundColor: paintedSurfaceBg,
    ),
    splashFactory: MaterialYouInkSplash.splashFactory,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: scheme.background,
    splashColor: Colors.black.withAlpha(40),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: fabBg,
      foregroundColor: paintedSurfaceFgColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      selectedItemColor: paintedSurfaceFgColor,
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: bottomNavBarBg,
      elevation: 0.0,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: paintedSurfaceBg,
      contentTextStyle: TextStyle(
        color: paintedSurfaceFgColor,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: paintedSurfaceBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.all(12.0),
    ),
    tooltipTheme: null, // Didnt change!
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
    androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
    iconTheme: IconThemeData(color: paintedSurfaceFgColor),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor:
          isDark ? materialYou.accent1.shade300 : materialYou.accent1.shade700,
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: colorfulSurfaceBg,
      contentTextStyle: TextStyle(color: colorfulSurfaceFg),
    ),
    textSelectionTheme: TextSelectionThemeData(
      // TODO: this is an blend
      cursorColor:
          isDark ? materialYou.accent1.shade300 : materialYou.accent1.shade100,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: paintedSurfaceBg,
      elevation: 0.0,
      selectedIconTheme: IconThemeData(
        color: paintedSurfaceFgColor,
      ),
      selectedLabelTextStyle: TextStyle(
        color: paintedSurfaceFgColor,
      ),
    ),
    timePickerTheme: TimePickerThemeData(),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    ),
    chipTheme: ChipThemeData.fromDefaults(
      secondaryColor: materialYou.accent1.shade100,
      labelStyle: TextStyle(
        color: materialYou.accent1.shade100.textColor,
      ),
      brightness: materialYou.accent1.shade100.textColor == Colors.white
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

ColorScheme colorSchemeFromMaterialYouColors(
    MaterialYouColors colors, bool isDark) {
  if (isDark) {
    return ColorScheme.dark(
      primary: colors.accent1[kDesaturatedSwatch]!,
      primaryVariant: colors.accent2[kDesaturatedSwatch]!,
      onPrimary: colors.accent1[kDesaturatedSwatch]!.textColor,
      secondary: colors.accent3[kDesaturatedSwatch]!,
      secondaryVariant: colors.accent3[kDesaturatedSwatch + 100]!,
      onSecondary: colors.accent3[kDesaturatedSwatch]!.textColor,
      background: colors.neutral1[900]!,
      onBackground: colors.neutral1[900]!.textColor,
      surface: colors.neutral2[900]!,
      onSurface: colors.neutral2[900]!.textColor,
    );
  }
  return ColorScheme.light(
    primary: colors.accent1[kDesaturatedSwatch]!,
    primaryVariant: colors.accent2[kDesaturatedSwatch]!,
    onPrimary: colors.accent1[kDesaturatedSwatch]!.textColor,
    secondary: colors.accent3[kDesaturatedSwatch]!,
    secondaryVariant: colors.accent3[kDesaturatedSwatch + 100]!,
    onSecondary: colors.accent3[kDesaturatedSwatch]!.textColor,
    background: colors.neutral1[10]!,
    onBackground: colors.neutral1[10]!.textColor,
    surface: colors.neutral2[10]!,
    onSurface: colors.neutral2[10]!.textColor,
  );
}
