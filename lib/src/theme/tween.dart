import 'package:flutter/material.dart';

import '../theme.dart';

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
