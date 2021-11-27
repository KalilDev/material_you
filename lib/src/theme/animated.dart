import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'tween.dart';

class AnimatedMonetColorScheme extends StatelessWidget {
  const AnimatedMonetColorScheme({
    Key? key,
    this.themeMode = ThemeMode.system,
    required this.child,
  }) : super(key: key);
  final ThemeMode themeMode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final useDarkTheme = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    final monetTheme = context.monetTheme;

    return _AnimatedMonetColorScheme(
      dark: monetTheme.dark,
      light: monetTheme.light,
      isDark: useDarkTheme,
      child: child,
    );
  }
}

class _AnimatedMonetColorScheme extends StatefulWidget {
  const _AnimatedMonetColorScheme({
    Key? key,
    required this.dark,
    required this.light,
    required this.isDark,
    required this.child,
  }) : super(key: key);
  final MonetColorScheme dark;
  final MonetColorScheme light;
  final bool isDark;
  final Widget child;

  @override
  __AnimatedMonetColorSchemeState createState() =>
      __AnimatedMonetColorSchemeState();
}

class __AnimatedMonetColorSchemeState extends State<_AnimatedMonetColorScheme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: kThemeChangeDuration);
  late MonetColorSchemeTween tween;

  @override
  void initState() {
    super.initState();
    if (widget.isDark) {
      _controller.value = 1.0;
    }
    _updateTween();
  }

  void _updateTween() => tween = MonetColorSchemeTween(
        begin: widget.light,
        end: widget.dark,
      );

  void didUpdateWidget(_AnimatedMonetColorScheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      _controller.animateTo(widget.isDark ? 1.0 : 0.0);
    }
    _updateTween();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<MonetColorScheme>(
        valueListenable: tween.animate(_controller),
        builder: (context, scheme, _) => InheritedMonetColorScheme(
          scheme: scheme,
          child: widget.child,
        ),
      );
}

class AnimatedMD3Theme extends ImplicitlyAnimatedWidget {
  const AnimatedMD3Theme({
    Key? key,
    required this.data,
    Curve curve = Curves.linear,
    Duration duration = kThemeAnimationDuration,
    VoidCallback? onEnd,
    required this.child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final MD3ThemeData data;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedMD3Theme> createState() =>
      _AnimatedMD3ThemeState();
}

class _AnimatedMD3ThemeState extends AnimatedWidgetBaseState<AnimatedMD3Theme> {
  MD3ThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(_data, widget.data,
            (dynamic value) => MD3ThemeDataTween(begin: value as MD3ThemeData))!
        as MD3ThemeDataTween;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedMD3Theme(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<MD3ThemeDataTween>('data', _data,
        showName: false, defaultValue: null));
  }
}
