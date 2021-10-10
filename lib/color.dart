import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_material_palette/flutter_material_palette.dart';

import 'material.dart';
import 'dart:math' as math;

// ignore: non_constant_identifier_names
Color HSLA(
  double hue, // 0-360
  double saturation,
  double luminosity, [
  double opacity = 1.0,
]) {
  final h = (hue / 360) % 1;
  double red, green, blue;

  if (saturation == 0) {
    red = green = blue = luminosity; // achromatic
  } else {
    double hue2rgb(double p, double q, double huePart) {
      if (huePart < 0) huePart += 1;
      if (huePart > 1) huePart -= 1;
      if (huePart < 1 / 6) return p + (q - p) * 6 * huePart;
      if (huePart < 1 / 2) return q;
      if (huePart < 2 / 3) return p + (q - p) * (2 / 3 - huePart) * 6;
      return p;
    }

    var q = luminosity < 0.5
        ? luminosity * (1 + saturation)
        : luminosity + saturation - luminosity * saturation;
    var p = 2 * luminosity - q;
    red = hue2rgb(p, q, h + 1 / 3);
    green = hue2rgb(p, q, h);
    blue = hue2rgb(p, q, h - 1 / 3);
  }

  return Color.fromARGB(
    (opacity * 255).round(),
    (red * 255).round(),
    (green * 255).round(),
    (blue * 255).round(),
  );
}

extension ColorE on Color {
  bool get isBlack => (value & 0x00FFFFFF) == 0;
  bool get isWhite => (value & 0x00FFFFFF) == 0xFFFFFF;
  bool get isMonochromatic => (red == green) && (green == blue);
  Color get variant => _mix(
        _multiply(this, this),
        this,
        0.70,
      ); // swatch 700

  MaterialColor deriveMaterialColor() {
    var baseLight = Color(0xFFFFFFFF);
    var baseDark = _multiply(this, this);

    return MaterialColor(value, {
      50: _mix(baseLight, this, 0.12),
      100: _mix(baseLight, this, 0.30),
      200: _mix(baseLight, this, 0.50),
      300: _mix(baseLight, this, 0.70),
      400: _mix(baseLight, this, 0.85),
      500: _mix(baseLight, this, 0.100),
      600: _mix(baseDark, this, 0.87),
      700: _mix(baseDark, this, 0.70),
      800: _mix(baseDark, this, 0.54),
      900: _mix(baseDark, this, 0.25),
    });
  }
}

/// Calculates the [rgbColor]s hue on a 0 to 1 scale,
/// as used by the HSL, HSP, and HSB color models.
double getHue(Color rgbColor) {
  double hue;

  final red = rgbColor.red;
  final green = rgbColor.green;
  final blue = rgbColor.blue;
  final rgb = [red, green, blue];

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

  return hue;
}

extension HSLColor on Color {
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

  double get saturation {
    if (isMonochromatic) {
      return 0;
    }

    final rgb = _rgbComponents.map((e) => e / 255);

    // Find greatest and smallest channel values
    final max = rgb.reduce(math.max);
    final min = rgb.reduce(math.min);
    final delta = max - min;

    // Calculate lightness
    final lightness = (max + min) / 2;
    // Calculate saturation
    final saturation =
        delta == 0 ? 0.0 : delta / (1 - (2 * lightness - 1).abs());

    return saturation;
  }

  List<int> get _rgbComponents => [red, green, blue];
  double get lightness {
    if (isBlack) return 0;
    if (isWhite) return 1;
    if (isMonochromatic) {
      return red / 255;
    }

    final rgb = _rgbComponents;

    final max = rgb.reduce(math.max);
    final min = rgb.reduce(math.min);

    final lightness = (max + min) / 2;

    return lightness / 100;
  }
}

_mix(Color a, Color b, double t) {
  final color = Color.fromARGB(
      ((b.alpha - a.alpha) * t + a.alpha).floor(),
      ((b.red - a.red) * t + a.red).floor(),
      ((b.green - a.green) * t + a.green).floor(),
      ((b.blue - a.blue) * t + a.blue).floor());
  return color;
}

Color _multiply(Color a, Color b) {
  final red = (a.red * b.red / 255).floor();
  final green = (a.green * b.green / 255).floor();
  final blue = (a.blue * b.blue / 255).floor();
  return Color.fromARGB(a.alpha, red, green, blue);
}

extension on MaterialColor {
  int swatchOfPrimary() {
    for (var i = 0; i < 10; i++) {
      final swatch = i == 0 ? 50 : 100 * i;
      final c = this[swatch];
      if (c == null) {
        continue;
      }
      if (c.value == value) {
        return swatch;
      }
    }
    return 500;
  }
}

const kDesaturatedLightTheme = true;

const kDesaturatedSwatch = 300;
const kDefaultSwatch = 500;
const kLightSwatch =
    kDesaturatedLightTheme ? kDesaturatedSwatch : kDefaultSwatch;
const kVariantSwatch = 900;

class TertiaryColorScheme implements ColorScheme {
  final ColorScheme _base;
  final Color _tertiary;
  final Color _tertiaryVariant;
  final Color _onTertiary;

  TertiaryColorScheme(
    this._base, {
    required Color tertiary,
    required Color tertiaryVariant,
    required Color onTertiary,
  })  : _tertiary = tertiary,
        _tertiaryVariant = tertiaryVariant,
        _onTertiary = onTertiary;

  @override
  Color get background => _base.background;

  @override
  Brightness get brightness => _base.brightness;

  @override
  ColorScheme copyWith({
    Color? primary,
    Color? primaryVariant,
    Color? secondary,
    Color? secondaryVariant,
    Color? tertiary,
    Color? tertiaryVariant,
    Color? surface,
    Color? background,
    Color? error,
    Color? onPrimary,
    Color? onSecondary,
    Color? onTertiary,
    Color? onSurface,
    Color? onBackground,
    Color? onError,
    Brightness? brightness,
  }) {
    return TertiaryColorScheme(
      _base.copyWith(
        primary: primary,
        primaryVariant: primaryVariant,
        secondary: secondary,
        secondaryVariant: secondaryVariant,
        surface: surface,
        background: background,
        error: error,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSurface: onSurface,
        onBackground: onBackground,
        onError: onError,
        brightness: brightness,
      ),
      tertiary: tertiary ?? this._tertiary,
      tertiaryVariant: tertiaryVariant ?? this._tertiaryVariant,
      onTertiary: onTertiary ?? this._onTertiary,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) =>
      _base.debugFillProperties(properties);

  @override
  Color get error => _base.error;

  @override
  Color get onBackground => _base.onBackground;

  @override
  Color get onError => _base.onError;

  @override
  Color get onPrimary => _base.onPrimary;

  @override
  Color get onSecondary => _base.onSecondary;

  @override
  Color get onSurface => _base.onSurface;

  @override
  Color get primary => _base.primary;

  @override
  Color get primaryVariant => _base.primaryVariant;

  @override
  Color get secondary => _base.secondary;

  @override
  Color get secondaryVariant => _base.secondaryVariant;

  @override
  Color get surface => _base.surface;

  @override
  DiagnosticsNode toDiagnosticsNode(
          {String? name, DiagnosticsTreeStyle? style}) =>
      _base.toDiagnosticsNode(name: name, style: style);

  @override
  String toStringShort() => _base.toStringShort();

  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      _base.toString(minLevel: minLevel);
}

extension ComplementaryE on TertiaryColorScheme {
  Color get tertiary => _tertiary;
  Color get tertiaryVariant => _tertiaryVariant;
  Color get onTertiary => _onTertiary;
}

extension Complementary on ColorScheme {
  static final _cache = Expando<MaterialColor>();
  static MaterialColor _colors(Color primary, Object key) {
    var cached = _cache[key];
    if (cached == null) {
      return _cache[key] = MaterialColors.deriveFrom(primary).triadicL;
    }
    print('get $cached');
    return cached;
  }

  // The color that is equidistant to both the primary and secondary color on
  // the color wheel at the far side.
  Color get tertiary {
    if (this is TertiaryColorScheme) {
      return ComplementaryE(this as TertiaryColorScheme).tertiary;
    }
    final colors = _colors(primary, this);
    final swatch =
        brightness == Brightness.dark ? kDesaturatedSwatch : kLightSwatch;
    return colors[swatch]!;
  }

  Color get tertiaryVariant {
    if (this is TertiaryColorScheme) {
      return ComplementaryE(this as TertiaryColorScheme).tertiaryVariant;
    }
    final colors = _colors(primary, this);
    return colors[kVariantSwatch]!;
  }

  Color get onTertiary {
    if (this is TertiaryColorScheme) {
      return ComplementaryE(this as TertiaryColorScheme).onTertiary;
    }
    return tertiary.textColor;
  }
}

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
