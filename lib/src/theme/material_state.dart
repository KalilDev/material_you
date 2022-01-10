import 'package:flutter/material.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';

@immutable
class MD3DraggableElevation extends MD3MaterialStateElevation {
  MD3DraggableElevation(
    MD3ElevationLevel regular,
    MD3ElevationLevel dragged,
  ) : super(
          regular,
          regular,
          dragged: dragged,
        );
}

@immutable
class MD3StateOverlayColor extends MaterialStateProperty<Color> {
  MD3StateOverlayColor(this.color, this.opacityTheme);

  final Color color;
  final MD3StateLayerOpacityTheme opacityTheme;

  @override
  Color resolve(Set<MaterialState> states) {
    states = materialStatesWithImplicits(states);
    final color = MaterialStateProperty.resolveAs(this.color, states);
    if (states.contains(MaterialState.dragged)) {
      return color.withOpacity(opacityTheme.dragged);
    }
    if (states.contains(MaterialState.pressed)) {
      return color.withOpacity(opacityTheme.pressed);
    }
    if (states.contains(MaterialState.hovered)) {
      return color.withOpacity(opacityTheme.hovered);
    }
    if (states.contains(MaterialState.focused)) {
      return color.withOpacity(opacityTheme.focused);
    }

    return Colors.transparent;
  }
}

@immutable
class MD3DisablableColor extends MaterialStateColor {
  MD3DisablableColor(
    this.color, {
    this.disabledOpacity = 0.38,
    this.disabledColor,
  }) : super(color.value);

  final Color color;
  final Color? disabledColor;
  final double disabledOpacity;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      final color = disabledColor ?? this.color;
      return MaterialStateProperty.resolveAs(color, states)
          .withOpacity(disabledOpacity);
    }

    return MaterialStateProperty.resolveAs(color, states);
  }
}

extension MD3MaterialStateElevationE
    on MaterialStateProperty<MD3ElevationLevel> {
  MaterialStateProperty<double> get value =>
      MaterialStateProperty.resolveWith((states) => resolve(states).value);
}

@immutable
class MD3ElevationTintableColor extends MaterialStateColor {
  MD3ElevationTintableColor(
    this.color,
    this.tintColor,
    this.elevation,
  ) : super(color.value);

  final Color color;
  final Color? tintColor;
  final MaterialStateProperty<MD3ElevationLevel>? elevation;

  @override
  Color resolve(Set<MaterialState> states) {
    if (tintColor != null && elevation != null) {
      return elevation!.resolve(states).overlaidColor(
            MaterialStateProperty.resolveAs(color, states),
            MaterialStateProperty.resolveAs(tintColor!, states),
          );
    }
    return MaterialStateProperty.resolveAs(color, states);
  }
}

@immutable
class _CallbackMD3MaterialStateElevation extends MD3MaterialStateElevation {
  _CallbackMD3MaterialStateElevation(this._resolve)
      : super(
          MD3ElevationLevel(0),
          MD3ElevationLevel(0),
        );
  MD3ElevationLevel get normal => resolve({});
  MD3ElevationLevel get hovered => resolve({MaterialState.hovered});
  MD3ElevationLevel? get dragged => resolve({MaterialState.dragged});
  MD3ElevationLevel? get focused => resolve({MaterialState.focused});
  MD3ElevationLevel? get disabled => resolve({MaterialState.disabled});
  MD3ElevationLevel? get pressed => resolve({
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      });

  final MD3ElevationLevel Function(Set<MaterialState> states) _resolve;

  @override
  MD3ElevationLevel resolve(Set<MaterialState> states) => _resolve(states);
}

/// Returns the set of all the [MaterialState]s implied by [states].
///
/// The [MaterialState]s must be used from the most specific to the least
/// specific, in the following order:
/// - [MaterialState.disabled]
/// - [MaterialState.error]
/// - [MaterialState.dragged]
/// - [MaterialState.pressed]
/// - [MaterialState.hovered]
/// - [MaterialState.focused]
/// - [MaterialState.scrolledUnder]
/// - [MaterialState.selected]
///
/// The implied states are the following:
///
/// [MaterialState.pressed]:
/// - [MaterialState.hovered]
/// - [MaterialState.focused]
Set<MaterialState> materialStatesWithImplicits(Set<MaterialState> states) => {
      if (states.contains(MaterialState.pressed)) MaterialState.focused,
      if (states.contains(MaterialState.pressed)) MaterialState.hovered,
      ...states,
    };

@immutable
class MD3MaterialStateElevation extends MD3ElevationLevel
    implements MaterialStateProperty<MD3ElevationLevel> {
  MD3MaterialStateElevation(
    this.normal,
    this.hovered, {
    this.dragged,
    this.focused,
    this.disabled,
    this.pressed,
  }) : super(normal.value);

  final MD3ElevationLevel normal;
  final MD3ElevationLevel hovered;
  final MD3ElevationLevel? dragged;
  final MD3ElevationLevel? focused;
  final MD3ElevationLevel? disabled;
  final MD3ElevationLevel? pressed;

  static MD3MaterialStateElevation resolveWith(
    MD3ElevationLevel Function(Set<MaterialState>) resolver,
  ) =>
      _CallbackMD3MaterialStateElevation(resolver);

  @override
  MD3ElevationLevel resolve(Set<MaterialState> states) {
    states = materialStatesWithImplicits(states);
    if (states.contains(MaterialState.disabled) && disabled != null) {
      return disabled!;
    }
    if (states.contains(MaterialState.dragged) && dragged != null) {
      return dragged!;
    }
    if (states.contains(MaterialState.pressed) && pressed != null) {
      return pressed!;
    }
    if (states.contains(MaterialState.hovered)) {
      return hovered;
    }
    if (states.contains(MaterialState.focused) && focused != null) {
      return focused!;
    }
    return normal;
  }
}

@immutable
class MD3DisablableProperty<T> extends MaterialStateProperty<T> {
  MD3DisablableProperty(this.normal, this.disabled);

  final T normal;
  final T disabled;
  @override
  T resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return MaterialStateProperty.resolveAs(disabled, states);
    }
    return MaterialStateProperty.resolveAs(normal, states);
  }
}

typedef MD3DisablableCursor = MD3DisablableProperty<MouseCursor>;
