import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'inherited.dart';
import 'model.dart';
import 'tween.dart';

typedef AnimatedMonetColorScheme
    = AnimatedMonetColorSchemes<NoAppScheme, NoAppTheme>;

class AnimatedMonetColorSchemes<S extends AppCustomColorScheme<S>,
    T extends AppCustomColorTheme<S, T>> extends StatelessWidget {
  const AnimatedMonetColorSchemes({
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
    final appCustomColors = InheritedAppCustomColorTheme.maybeOf<S, T>(context);

    return _AnimatedMonetColorScheme<S, T>(
      dark: monetTheme.dark,
      light: monetTheme.light,
      darkApp: appCustomColors?.dark,
      lightApp: appCustomColors?.light,
      isDark: useDarkTheme,
      child: child,
    );
  }
}

class _AnimatedMonetColorScheme<S extends AppCustomColorScheme<S>,
    T extends AppCustomColorTheme<S, T>> extends StatefulWidget {
  const _AnimatedMonetColorScheme({
    Key? key,
    required this.dark,
    required this.light,
    required this.darkApp,
    required this.lightApp,
    required this.isDark,
    required this.child,
  }) : super(key: key);
  final MonetColorScheme dark;
  final MonetColorScheme light;
  final S? darkApp;
  final S? lightApp;
  final bool isDark;
  final Widget child;

  @override
  __AnimatedMonetColorSchemeState<S, T> createState() =>
      __AnimatedMonetColorSchemeState();
}

class __AnimatedMonetColorSchemeState<S extends AppCustomColorScheme<S>,
        T extends AppCustomColorTheme<S, T>>
    extends State<_AnimatedMonetColorScheme<S, T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: kThemeChangeDuration);
  late AppCustomColorSchemeTween<S> appTween;
  late MonetColorSchemeTween tween;
  final _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.isDark) {
      _controller.value = 1.0;
    }
    _updateTween();
    _updateAppTween();
  }

  void _updateTween() => tween = MonetColorSchemeTween(
        begin: widget.light,
        end: widget.dark,
      );
  void _updateAppTween() => appTween = AppCustomColorSchemeTween<S>(
        begin: widget.lightApp,
        end: widget.darkApp,
      );

  @override
  void didUpdateWidget(_AnimatedMonetColorScheme<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      _controller.animateTo(widget.isDark ? 1.0 : 0.0);
    }
    if (!identical(widget.light, oldWidget.light) ||
        !identical(widget.dark, oldWidget.dark)) {
      _updateTween();
    }
    if (!identical(widget.lightApp, oldWidget.lightApp) ||
        !identical(widget.darkApp, oldWidget.darkApp)) {
      _updateAppTween();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _maybeAppScheme({required Widget child}) {
    final app = appTween.evaluate(_controller);
    if (app == null) {
      return child;
    }
    return InheritedAppCustomColorScheme<S>(data: app, child: child);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => InheritedMonetColorScheme(
          scheme: tween.evaluate(_controller),
          child: _maybeAppScheme(
            child: child!,
          ),
        ),
        child: KeyedSubtree(
          key: _childKey,
          child: widget.child,
        ),
      );
}

class AnimatedAppCustomColorTheme<S extends AppCustomColorScheme<S>,
    T extends AppCustomColorTheme<S, T>> extends ImplicitlyAnimatedWidget {
  const AnimatedAppCustomColorTheme({
    Key? key,
    required this.data,
    Curve curve = Curves.linear,
    Duration duration = kThemeAnimationDuration,
    VoidCallback? onEnd,
    required this.child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final T data;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedAppCustomColorTheme<S, T>> createState() =>
      _AnimatedAppCustomColorThemeState<S, T>();
}

class _AnimatedAppCustomColorThemeState<S extends AppCustomColorScheme<S>,
        T extends AppCustomColorTheme<S, T>>
    extends AnimatedWidgetBaseState<AnimatedAppCustomColorTheme<S, T>> {
  AppCustomColorThemeTween<S, T>? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
            _data,
            widget.data,
            (dynamic value) =>
                AppCustomColorThemeTween<S, T>(begin: value as T))!
        as AppCustomColorThemeTween<S, T>;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedAppCustomColorTheme<S, T>(
      data: _data!.evaluate(animation)!,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<AppCustomColorThemeTween>('data', _data,
        showName: false, defaultValue: null));
  }
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
