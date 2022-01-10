import 'package:flutter/material.dart';

import 'model.dart';

class AppCustomColorSchemeTween<S extends AppCustomColorScheme<S>>
    extends Tween<S?> {
  AppCustomColorSchemeTween({S? begin, S? end}) : super(begin: begin, end: end);

  @override
  S? lerp(double t) {
    if (begin == null && end == null) {
      return null;
    }
    if (begin == null) {
      return t < 0.5 ? null : end;
    }
    if (end == null) {
      return t < 0.5 ? begin : null;
    }
    return begin!.lerpWith(end!, t);
  }
}

class AppCustomColorThemeTween<S extends AppCustomColorScheme<S>,
    T extends AppCustomColorTheme<S, T>> extends Tween<T?> {
  AppCustomColorThemeTween({T? begin, T? end}) : super(begin: begin, end: end);

  @override
  T? lerp(double t) {
    if (begin == null && end == null) {
      return null;
    }
    if (begin == null) {
      return t < 0.5 ? null : end;
    }
    if (end == null) {
      return t < 0.5 ? begin : null;
    }
    return begin!.lerpWith(end!, t);
  }
}

class MonetColorSchemeTween extends Tween<MonetColorScheme> {
  MonetColorSchemeTween({MonetColorScheme? begin, MonetColorScheme? end})
      : super(begin: begin, end: end);

  @override
  MonetColorScheme lerp(double t) => MonetColorScheme.lerp(begin!, end!, t);
}

class MD3ThemeDataTween extends Tween<MD3ThemeData> {
  MD3ThemeDataTween({MD3ThemeData? begin, MD3ThemeData? end})
      : super(begin: begin, end: end);

  @override
  MD3ThemeData lerp(double t) => MD3ThemeData.lerp(begin!, end!, t);
}
