import 'package:flutter/material.dart';
import 'morphable_path.dart';
import 'dart:math' as math;

class _BorderFromMorphable extends OutlinedBorder {
  final MorphableBorder _base;
  _BorderFromMorphable(this._base, {BorderSide? side})
      : super(side: side ?? _base.side);

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _base.copyWith(side: side).toOutlinedBorder();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _base.getInnerPath(rect, textDirection: textDirection).toPath();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _base.getOuterPath(rect, textDirection: textDirection).toPath();

  @override
  OutlinedBorder scale(double t) => _base.scale(t).toOutlinedBorder();

  OutlinedBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is _BorderFromMorphable) {
      final added = _base.add(other._base, reversed: reversed)!;
      return added.toOutlinedBorder();
    }
    final added = _base.add(other, reversed: reversed);
    return added?.toOutlinedBorder();
  }

  OutlinedBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a == null) return scale(t);
    if (a is _BorderFromMorphable) {
      final lerped = _base.lerpFrom(a._base, t);
      return lerped?.toOutlinedBorder();
    }
    final lerped = _base.lerpFrom(a, t);

    return lerped?.toOutlinedBorder();
  }

  OutlinedBorder? lerpTo(ShapeBorder? b, double t) {
    if (b == null) return scale(1 - t);
    if (b is _BorderFromMorphable) {
      final lerped = _base.lerpTo(b._base, t);
      return lerped?.toOutlinedBorder();
    }
    final lerped = _base.lerpTo(b, t);
    return lerped?.toOutlinedBorder();
  }

  @override
  EdgeInsetsGeometry get dimensions => _base.dimensions;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) =>
      _base.paint(canvas, rect, textDirection: textDirection);
}

abstract class MorphableBorder extends OutlinedBorder {
  const MorphableBorder({BorderSide side = BorderSide.none})
      : super(side: side);
  static OutlinedBorder toBorder(OutlinedBorder base) =>
      base is MorphableBorder ? base.toOutlinedBorder() : base;
  OutlinedBorder toOutlinedBorder() => _BorderFromMorphable(this);
  @override
  MorphableBorder copyWith({BorderSide? side});

  @override
  MorphablePath getInnerPath(Rect rect, {TextDirection? textDirection});

  @override
  MorphablePath getOuterPath(Rect rect, {TextDirection? textDirection});

  @override
  MorphableBorder scale(double t);

  MorphableBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is MorphableBorder) {
      return reversed
          ? _AddedMorphableBorder(other, this)
          : _AddedMorphableBorder(this, other);
    }
  }

  MorphableBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a == null) return scale(t);
    if (a is MorphableBorder) {
      return _LerpMorphableBorder(a, this, t);
    }
    if (a is RoundedRectangleBorder) {
      return _LerpMorphableBorder(RoundedRectangleMorphableBorder(a), this, t);
    }
    if (a is CircleBorder) {
      return _LerpMorphableBorder(CircleMorphableBorder(a), this, t);
    }
    return null;
  }

  MorphableBorder? lerpTo(ShapeBorder? b, double t) {
    if (b == null) return scale(1 - t);
    if (b is MorphableBorder) {
      return _LerpMorphableBorder(this, b, t);
    }
    if (b is RoundedRectangleBorder) {
      return _LerpMorphableBorder(this, RoundedRectangleMorphableBorder(b), t);
    }
    if (b is CircleBorder) {
      return _LerpMorphableBorder(this, CircleMorphableBorder(b), t);
    }
    return null;
  }
}

abstract class _AdaptableMorphableBorder extends MorphableBorder {
  final OutlinedBorder base;

  _AdaptableMorphableBorder(this.base) : super(side: base.side);

  OutlinedBorder toOutlinedBorder() => base;

  @override
  _AdaptableMorphableBorder copyWith({BorderSide? side});
  @override
  _AdaptableMorphableBorder scale(double t);

  @override
  EdgeInsetsGeometry get dimensions => base.dimensions;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) =>
      base.paint(canvas, rect, textDirection: textDirection);
}

class CircleMorphableBorder extends _AdaptableMorphableBorder {
  CircleMorphableBorder(CircleBorder base) : super(base);

  CircleBorder get base => super.base as CircleBorder;

  @override
  _AdaptableMorphableBorder copyWith({BorderSide? side}) =>
      CircleMorphableBorder(base.copyWith(side: side));

  @override
  MorphablePath getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return MorphablePath()
      ..addOval(Rect.fromCircle(
        center: rect.center,
        radius: math.max(0.0, rect.shortestSide / 2.0 - side.width),
      ));
  }

  @override
  MorphablePath getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return MorphablePath()
      ..addOval(Rect.fromCircle(
        center: rect.center,
        radius: rect.shortestSide / 2.0,
      ));
  }

  @override
  _AdaptableMorphableBorder scale(double t) =>
      CircleMorphableBorder(base.scale(t) as CircleBorder);
}

class RoundedRectangleMorphableBorder extends _AdaptableMorphableBorder {
  RoundedRectangleMorphableBorder(RoundedRectangleBorder base) : super(base);

  RoundedRectangleBorder get base => super.base as RoundedRectangleBorder;

  @override
  _AdaptableMorphableBorder copyWith({BorderSide? side}) =>
      RoundedRectangleMorphableBorder(base.copyWith(side: side));

  @override
  MorphablePath getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return MorphablePath()
      ..addRRect(base.borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(side.width));
  }

  @override
  MorphablePath getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return MorphablePath()
      ..addRRect(base.borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  _AdaptableMorphableBorder scale(double t) =>
      RoundedRectangleMorphableBorder(base.scale(t) as RoundedRectangleBorder);
}

class _LerpMorphableBorder extends MorphableBorder {
  final MorphableBorder a;
  final MorphableBorder b;
  final double t;

  _LerpMorphableBorder(this.a, this.b, this.t, {BorderSide? side})
      : super(side: side ?? BorderSide.lerp(a.side, b.side, t));

  @override
  MorphableBorder copyWith({BorderSide? side}) =>
      _LerpMorphableBorder(a, b, t, side: side ?? this.side);

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsetsGeometry.lerp(a.dimensions, b.dimensions, t)!;

  @override
  MorphablePath getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      MorphablePath.morph(a.getInnerPath(rect, textDirection: textDirection),
          b.getInnerPath(rect, textDirection: textDirection), t);

  @override
  MorphablePath getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      MorphablePath.morph(a.getOuterPath(rect, textDirection: textDirection),
          b.getOuterPath(rect, textDirection: textDirection), t);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final inner = getInnerPath(rect, textDirection: textDirection).toPath();
    final outer = getOuterPath(rect, textDirection: textDirection).toPath();
    final path = Path.combine(PathOperation.intersect, outer, inner);
    final paint = side.toPaint()
      ..strokeWidth = 0
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  MorphableBorder scale(double t) =>
      _LerpMorphableBorder(a, b, this.t, side: side.scale(t));
}

class _AddedMorphableBorder extends MorphableBorder {
  final MorphableBorder a;
  final MorphableBorder b;
  _AddedMorphableBorder(this.a, this.b, {BorderSide side = BorderSide.none})
      : super(side: side);

  @override
  MorphableBorder copyWith({BorderSide? side}) =>
      _AddedMorphableBorder(a, b, side: side ?? this.side);

  @override
  EdgeInsetsGeometry get dimensions => a.dimensions.add(b.dimensions);

  @override
  MorphablePath getInnerPath(Rect rect, {TextDirection? textDirection}) => a
      .getInnerPath(rect, textDirection: textDirection)
    ..addPath(b.getInnerPath(rect, textDirection: textDirection), Offset.zero);

  @override
  MorphablePath getOuterPath(Rect rect, {TextDirection? textDirection}) => a
      .getOuterPath(rect, textDirection: textDirection)
    ..addPath(b.getOuterPath(rect, textDirection: textDirection), Offset.zero);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    a.paint(canvas, rect, textDirection: textDirection);
    b.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  MorphableBorder scale(double t) =>
      _AddedMorphableBorder(a, b, side: side.scale(t));
}
