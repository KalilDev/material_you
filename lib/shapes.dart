import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' as vec;
import 'material.dart';
import 'dart:math' as math;

/// A border that fits a circle within the available space.
///
/// Typically used with [ShapeDecoration] to draw a circle.
///
/// The [dimensions] assume that the border is being used in a square space.
/// When applied to a rectangular space, the border paints in the center of the
/// rectangle.
///
/// See also:
///
///  * [BorderSide], which is used to describe each side of the box.
///  * [Border], which, when used with [BoxDecoration], can also
///    describe a circle.
class WobblyBorder extends _CompoundableBorder {
  /// Create a circle border.
  ///
  /// The [side] argument must not be null.
  const WobblyBorder({
    BorderSide side = BorderSide.none,
    this.vertices = 8,
    this.initialAngle = 0.0,
  })  : assert(side != null),
        super(side: side);
  factory WobblyBorder.square({
    BorderSide side = BorderSide.none,
  }) =>
      WobblyBorder(
        vertices: 4,
        initialAngle: math.pi / 4,
        side: side,
      );
  factory WobblyBorder.triangle({
    BorderSide side = BorderSide.none,
  }) =>
      WobblyBorder(
        vertices: 3,
        initialAngle: math.pi,
        side: side,
      );
  final int vertices;
  final double initialAngle;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(_heightDiffFor(Offset.zero & Size(100, 100)));
  }

  @override
  ShapeBorder scale(double t) => WobblyBorder(side: side.scale(t));

  @override
  ShapeBorder? safeLerpFrom(ShapeBorder? a, double t) {
    if (a is WobblyBorder && a.vertices == vertices)
      return WobblyBorder(
        side: BorderSide.lerp(a.side, side, t),
        initialAngle: lerpDouble(a.initialAngle, initialAngle, t)!,
        vertices: vertices,
      );
    return super.safeLerpFrom(a, t);
  }

  @override
  ShapeBorder? safeLerpTo(ShapeBorder? b, double t) {
    if (b is WobblyBorder && b.vertices == vertices)
      return WobblyBorder(
        side: BorderSide.lerp(side, b.side, t),
        initialAngle: lerpDouble(initialAngle, b.initialAngle, t)!,
        vertices: vertices,
      );
    return super.safeLerpTo(b, t);
  }

  Rect _reducedRect(Rect rect, double padding) => Rect.fromLTWH(
        rect.left + padding,
        rect.top + padding,
        math.max(0.0, rect.width - 2 * padding),
        math.max(0.0, rect.height - 2 * padding),
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _pathForRect(
        _reducedRect(rect, side.width / 2),
        textDirection: textDirection,
      );

  double _heightDiffFor(Rect rect) => (rect.shortestSide / _stepCount) * 1.2;
  int get _stepCount => vertices * 2;
  Offset _flipAround(Offset point, Offset anchor) => anchor + (anchor - point);
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _pathForRect(rect);
  double get angleFrac => (2 * math.pi) / _stepCount;
  double get angleDistanceToSupport =>
      angleFrac / (2 + (vertices - 3) * (1 / 5));
  double radiusCompensation(double heightDiff) =>
      heightDiff * ((vertices - 3) * (1 / 5) * 0.15).clamp(0.0, 1.0);

  Path _pathForRect(Rect rect, {TextDirection? textDirection}) {
    final radius =
        (rect.shortestSide / 2.0) + radiusCompensation(_heightDiffFor(rect));
    final innerRadius = radius - _heightDiffFor(rect),
        mediumRadius = radius - (_heightDiffFor(rect) / 2);
    final center = rect.center;
    final cx = center.dx, cy = center.dy;

    final halfAngle = angleFrac / 2;
    var lastPoint = Offset(
      math.sin(initialAngle + halfAngle) * mediumRadius + cx,
      math.cos(initialAngle + halfAngle) * mediumRadius + cy,
    );
    Offset pointAt(double theta, double radius) => Offset(
          math.sin(theta) * radius + cx,
          math.cos(theta) * radius + cy,
        );
    final path = Path()..moveTo(lastPoint.dx, lastPoint.dy);

    void cubic(Offset c1, Offset c2, Offset target) {
      path.cubicTo(
        c1.dx,
        c1.dy,
        c2.dx,
        c2.dy,
        target.dx,
        target.dy,
      );
      c1 = c1 / rect.shortestSide;
      c2 = c2 / rect.shortestSide;
      target = target / rect.shortestSide;
    }

    for (var i = 0, angle = initialAngle + halfAngle;
        i < _stepCount;
        i++, angle += angleFrac) {
      final inner = i.isEven;
      final nextAngle = angle + angleFrac;

      if (inner) {
        cubic(
          pointAt(angle + angleDistanceToSupport, innerRadius),
          pointAt(nextAngle - angleDistanceToSupport, innerRadius),
          pointAt(nextAngle, mediumRadius),
        );
        continue;
      }
      final previousControl = pointAt(
        angle - angleDistanceToSupport,
        innerRadius,
      );
      final current = pointAt(
        angle,
        mediumRadius,
      );
      final nextControl = pointAt(
        nextAngle + angleDistanceToSupport,
        innerRadius,
      );
      final next = pointAt(
        nextAngle,
        mediumRadius,
      );
      final firstControl = _flipAround(previousControl, current);
      final secondControl = _flipAround(nextControl, next);
      cubic(firstControl, secondControl, next);
    }
    stdout.write("\n");
    return path..close();
  }

  @override
  WobblyBorder copyWith({BorderSide? side}) {
    return WobblyBorder(
      side: side ?? this.side,
      vertices: vertices,
      initialAngle: initialAngle,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.solid) {
      return;
    }
    canvas.drawPath(
      _pathForRect(
        _reducedRect(rect, side.width / 2),
        textDirection: textDirection,
      ),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is WobblyBorder &&
        other.side == side &&
        other.vertices == vertices &&
        other.initialAngle == initialAngle;
  }

  @override
  int get hashCode => hashList([side, vertices, initialAngle]);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'WobblyBorder')}($side)';
  }
}

extension on Radius {
  Radius scale(double t) => Radius.elliptical(t * x, t * y);
}

class TearBorder extends _CompoundableBorder {
  /// Create a tear border.
  ///
  /// The [side] argument must not be null.
  const TearBorder({
    BorderSide side = BorderSide.none,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  })  : assert(side != null),
        super(side: side);
  final Radius? topLeft;
  final Radius? topRight;
  final Radius? bottomLeft;
  final Radius? bottomRight;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(50);
  }

  List<Radius?> get radii => [
        topLeft,
        bottomLeft,
        bottomRight,
        topRight,
      ];

  @override
  ShapeBorder scale(double t) => TearBorder(
        side: side.scale(t),
        topLeft: topLeft?.scale(t),
        topRight: topRight?.scale(t),
        bottomLeft: bottomLeft?.scale(t),
        bottomRight: bottomRight?.scale(t),
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _getPath(
        rect,
        textDirection: textDirection,
        borderWidth: side.width,
      );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect, textDirection: textDirection);

  Path _getPath(Rect rect,
      {TextDirection? textDirection, double borderWidth = 0.0}) {
    final deg90 = math.pi / 2;
    final radius = (rect.shortestSide / 2.0) - borderWidth / 2;
    Offset pointAt(int i) => Offset(
          math.sin(deg90 * (i + 2)) * radius + rect.center.dx,
          math.cos(deg90 * (i + 2)) * radius + rect.center.dy,
        );
    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    bool drawCircular(int i) {
      final curve = radii[i];
      final nextPoint = pointAt(i + 1);
      if (curve == null) {
        path.arcToPoint(
          nextPoint,
          clockwise: false,
          radius: Radius.circular(radius),
        );
        return true;
      }
      return false;
    }

    if (!drawCircular(0)) {
      final curve = radii[0]!;
      final next = pointAt(1);
      path
        ..relativeLineTo(-radius + curve.x, 0)
        ..relativeQuadraticBezierTo(
          -curve.x,
          0,
          -curve.x,
          curve.y,
        )
        ..lineTo(next.dx, next.dy);
    }
    if (!drawCircular(1)) {
      final curve = radii[1]!;
      final next = pointAt(2);
      path
        ..relativeLineTo(0, radius - curve.y)
        ..relativeQuadraticBezierTo(
          0,
          curve.y,
          curve.x,
          curve.y,
        )
        ..lineTo(next.dx, next.dy);
    }
    if (!drawCircular(2)) {
      final curve = radii[2]!;
      final next = pointAt(3);
      path
        ..relativeLineTo(radius - curve.x, 0)
        ..relativeQuadraticBezierTo(
          curve.x,
          0,
          curve.x,
          -curve.y,
        )
        ..lineTo(next.dx, next.dy);
    }
    if (!drawCircular(3)) {
      final curve = radii[3]!;
      final next = pointAt(4);
      path
        ..relativeLineTo(0, -radius + curve.y)
        ..relativeQuadraticBezierTo(
          0,
          -curve.y,
          -curve.x,
          -curve.y,
        )
        ..lineTo(next.dx, next.dy);
    }
    return path;
  }

  @override
  TearBorder copyWith({
    BorderSide? side,
  }) {
    return TearBorder(side: side ?? this.side);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.solid) {
      return;
    }
    canvas.drawPath(
      _getPath(
        rect,
        textDirection: textDirection,
        borderWidth: side.width / 2,
      ),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TearBorder &&
        other.side == side &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomLeft == bottomLeft &&
        other.bottomRight == bottomRight;
  }

  @override
  int get hashCode => hashList([side, ...radii]);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'TearBorder')}($side)';
  }

  @override
  ShapeBorder? safeLerpFrom(ShapeBorder? a, double t) => null;

  @override
  ShapeBorder? safeLerpTo(ShapeBorder? b, double t) => null;
}

class RoundedTriangleBorder extends _CompoundableBorder {
  /// Create a circle border.
  ///
  /// The [side] argument must not be null.
  const RoundedTriangleBorder({
    BorderSide side = BorderSide.none,
  })  : assert(side != null),
        super(side: side);

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(50);
  }

  @override
  ShapeBorder scale(double t) => RoundedTriangleBorder(side: side.scale(t));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _getPath(
        rect,
        textDirection: textDirection,
        borderWidth: side.width,
      );

  Path _getPath(Rect rect,
      {TextDirection? textDirection, double borderWidth = 0.0}) {
    rect = Rect.fromLTRB(
      rect.left + borderWidth,
      rect.top + borderWidth,
      rect.right - borderWidth,
      rect.bottom - borderWidth,
    );
    final width = rect.width, height = rect.height;
    final sx = rect.topLeft.dx, sy = rect.topLeft.dy;
    final path = Path()
      ..moveTo(
          0.2622083333333333 * width + sx, 0.15379166666666666 * height + sy)
      ..cubicTo(
          0.31133333333333335 * width + sx,
          0.05591666666666667 * height + sy,
          0.3858333333333333 * width + sx,
          0 * height + sy,
          0.5014583333333333 * width + sx,
          0 * height + sy)
      ..cubicTo(
          0.6141666666666666 * width + sx,
          0 * height + sy,
          0.6886666666666666 * width + sx,
          0.05591666666666667 * height + sy,
          0.7377916666666667 * width + sx,
          0.15379166666666666 * height + sy)
      ..lineTo(0.9761666666666667 * width + sx, 0.629 * height + sy)
      ..cubicTo(
          1.02375 * width + sx,
          0.7280000000000001 * height + sy,
          0.9936666666666666 * width + sx,
          0.855625 * height + sy,
          0.9029583333333333 * width + sx,
          0.9319999999999999 * height + sy)
      ..cubicTo(
          0.8225416666666666 * width + sx,
          0.9997083333333333 * height + sy,
          0.7012916666666666 * width + sx,
          1.0146666666666666 * height + sy,
          0.6065416666666666 * width + sx,
          0.9669166666666666 * height + sy)
      ..cubicTo(
          0.5402166666666667 * width + sx,
          0.9334916666666667 * height + sy,
          0.45978333333333327 * width + sx,
          0.9334916666666667 * height + sy,
          0.3934583333333333 * width + sx,
          0.9669166666666666 * height + sy)
      ..cubicTo(
          0.2987083333333333 * width + sx,
          1.0146666666666666 * height + sy,
          0.17745833333333336 * width + sx,
          0.9997083333333333 * height + sy,
          0.09704166666666668 * width + sx,
          0.9319999999999999 * height + sy)
      ..cubicTo(
          0.006333333333333333 * width + sx,
          0.855625 * height + sy,
          -0.022833333333333334 * width + sx,
          0.7270416666666667 * height + sy,
          0.02383333333333333 * width + sx,
          0.629 * height + sy)
      ..close();
    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _getPath(
        rect,
        textDirection: textDirection,
      );

  @override
  RoundedTriangleBorder copyWith({BorderSide? side}) {
    return RoundedTriangleBorder(side: side ?? this.side);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.solid) {
      return;
    }
    canvas.drawPath(
      _getPath(rect, textDirection: textDirection, borderWidth: side.width / 2),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RoundedTriangleBorder && other.side == side;
  }

  @override
  int get hashCode => side.hashCode;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'RoundedTriangleBorder')}($side)';
  }
}

class PillBorder extends _CompoundableBorder {
  /// Create a pill border.
  ///
  /// The [side] argument must not be null.
  const PillBorder({
    BorderSide side = BorderSide.none,
    this.right = true,
    this.radiusFrac = 0.75,
  })  : assert(side != null),
        super(side: side);
  factory PillBorder.tiltedRight({
    BorderSide side = BorderSide.none,
    double radiusFrac = 0.75,
  }) =>
      PillBorder(
        right: true,
        side: side,
        radiusFrac: radiusFrac,
      );
  factory PillBorder.tiltedLeft({
    BorderSide side = BorderSide.none,
    double radiusFrac = 0.75,
  }) =>
      PillBorder(
        right: false,
        side: side,
        radiusFrac: radiusFrac,
      );
  final bool right;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(100);
  }

  @override
  ShapeBorder scale(double t) => PillBorder(
        side: side.scale(t),
        right: right,
        radiusFrac: radiusFrac,
      );

  @override
  ShapeBorder? safeLerpFrom(ShapeBorder? a, double t) {
    if (a is PillBorder)
      return PillBorder(
        side: BorderSide.lerp(a.side, side, t),
        right: right,
        radiusFrac: lerpDouble(a.radiusFrac, radiusFrac, t)!,
      );
    return super.safeLerpFrom(a, t);
  }

  @override
  ShapeBorder? safeLerpTo(ShapeBorder? b, double t) {
    if (b is PillBorder)
      return PillBorder(
        side: BorderSide.lerp(side, b.side, t),
        right: right,
        radiusFrac: lerpDouble(radiusFrac, b.radiusFrac, t)!,
      );
    return super.safeLerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect, textDirection: textDirection, borderWidth: side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect, textDirection: textDirection);
  Path _getPath(Rect rect,
      {TextDirection? textDirection, double borderWidth = 0.0}) {
    final radius = this.radius(rect.height - 2 * borderWidth);
    final cx = rect.center.dx, cy = rect.center.dy;
    final dx = (cos(math.pi / 4) * radius * radiusFrac) / 2,
        dy = (sin(math.pi / 4) * radius * radiusFrac) / 2;

    final sideCoeff = right ? 1 : -1;

    final c1 = Offset(cx - (dx * sideCoeff), cy + dy),
        c2 = Offset(cx + (dx * sideCoeff), cy - dy);

    final rx = sqrt2 * radius / 2, ry = sideCoeff * sqrt2 * radius / 2;
    final path = Path()
      ..moveTo(c1.dx - rx, c1.dy - ry)
      ..lineTo(c2.dx - rx, c2.dy - ry)
      ..arcToPoint(
        Offset(c2.dx + rx, c2.dy + ry),
        radius: Radius.elliptical(rx, ry),
      )
      ..lineTo(c1.dx + rx, c1.dy + ry)
      ..arcToPoint(
        Offset(c1.dx - rx, c1.dy - ry),
        radius: Radius.circular(radius),
      );
    return path;
  }

  final double radiusFrac;

  double radius(double height) =>
      height / (2 + radiusFrac * math.sin(math.pi / 4));

  @override
  PillBorder copyWith({BorderSide? side}) {
    return PillBorder(
      side: side ?? this.side,
      right: right,
      radiusFrac: radiusFrac,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.solid) {
      return;
    }
    canvas.drawPath(
      _getPath(
        rect,
        textDirection: textDirection,
        borderWidth: side.width / 2,
      ),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is PillBorder && other.side == side && other.right == right;
  }

  @override
  int get hashCode => hashList([side, right]);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'PillBorder')}($side)';
  }
}

class DiamondBorder extends _CompoundableBorder {
  /// Create a pill border.
  ///
  /// The [side] argument must not be null.
  const DiamondBorder.only({
    BorderSide side = BorderSide.none,
    this.top = Radius.zero,
    this.left = Radius.zero,
    this.right = Radius.zero,
    this.bottom = Radius.zero,
  })  : assert(side != null),
        super(side: side);
  const DiamondBorder.all({
    BorderSide side = BorderSide.none,
    required Radius radius,
  })  : assert(side != null),
        top = radius,
        left = radius,
        right = radius,
        bottom = radius,
        super(side: side);
  final Radius top;
  final Radius left;
  final Radius right;
  final Radius bottom;
  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(100);
  }

  @override
  ShapeBorder scale(double t) => DiamondBorder.only(
        side: side.scale(t),
        top: top.scale(t),
        left: left.scale(t),
        right: right.scale(t),
        bottom: bottom.scale(t),
      );

  @override
  ShapeBorder? safeLerpFrom(ShapeBorder? a, double t) {
    if (a is DiamondBorder)
      return DiamondBorder.only(
        side: BorderSide.lerp(a.side, side, t),
        top: Radius.lerp(a.top, top, t)!,
        left: Radius.lerp(a.left, left, t)!,
        right: Radius.lerp(a.right, right, t)!,
        bottom: Radius.lerp(a.bottom, bottom, t)!,
      );
    return super.safeLerpFrom(a, t);
  }

  @override
  ShapeBorder? safeLerpTo(ShapeBorder? b, double t) {
    if (b is DiamondBorder)
      return DiamondBorder.only(
        side: BorderSide.lerp(side, side, t),
        top: Radius.lerp(top, b.top, t)!,
        left: Radius.lerp(left, b.left, t)!,
        right: Radius.lerp(right, b.right, t)!,
        bottom: Radius.lerp(bottom, b.bottom, t)!,
      );
    return super.safeLerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect, textDirection: textDirection, borderWidth: side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect, textDirection: textDirection);
  Path _getPath(Rect rect,
      {TextDirection? textDirection, double borderWidth = 0.0}) {
    final transform = Matrix4.identity()
      ..translate(rect.topCenter.dx, rect.topCenter.dy)
      ..rotateZ(pi / 4)
      ..scale(1 / sqrt2);
    final rrect = BorderRadius.only(
      topLeft: top,
      topRight: right,
      bottomLeft: left,
      bottomRight: bottom,
    ).toRRect(rect);
    return (Path()..addRRect(rrect)).transform(transform.storage);
  }

  @override
  DiamondBorder copyWith({
    BorderSide? side,
  }) {
    return DiamondBorder.only(
      side: side ?? this.side,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.solid) {
      return;
    }
    canvas.drawPath(
      _getPath(
        rect,
        textDirection: textDirection,
        borderWidth: side.width / 2,
      ),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is DiamondBorder &&
        other.side == side &&
        other.top == top &&
        other.left == left &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => hashList([side, right]);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'DiamondBorder')}($side)';
  }
}

abstract class _CompoundableBorder extends OutlinedBorder {
  const _CompoundableBorder({required BorderSide side}) : super(side: side);
  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) =>
      safeLerpFrom(a, t) ?? _PathIntersectioningShape(a, this, t);
  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) =>
      safeLerpTo(b, t) ?? _PathIntersectioningShape(this, b, t);
  ShapeBorder? safeLerpFrom(ShapeBorder? a, double t) => super.lerpFrom(a, t);
  ShapeBorder? safeLerpTo(ShapeBorder? b, double t) => super.lerpTo(b, t);
}

/// Represents the addition of two otherwise-incompatible borders.
///
/// The borders are listed from the outside to the inside.
class _SizeTransitioningShape extends ShapeBorder {
  _SizeTransitioningShape(this.a, this.b, this.t);
  final ShapeBorder? a;
  final ShapeBorder? b;
  final double t;
  List<ShapeBorder?> get borders => [a, b];
  Iterable<ShapeBorder> get nonNullBorders =>
      borders.where((e) => e != null).cast();

  @override
  EdgeInsetsGeometry get dimensions {
    return nonNullBorders.fold<EdgeInsetsGeometry>(
      EdgeInsets.zero,
      (EdgeInsetsGeometry previousValue, ShapeBorder border) {
        return previousValue.add(border.dimensions);
      },
    );
  }

  @override
  ShapeBorder add(ShapeBorder other, {bool reversed = false}) {
    if (reversed) {
      return _SizeTransitioningShape(other, this, t);
    }
    return _SizeTransitioningShape(this, other, t);
  }

  @override
  ShapeBorder scale(double t) {
    return _SizeTransitioningShape(
      a?.scale(t),
      b?.scale(t),
      this.t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    return _SizeTransitioningShape.lerp(a, this, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    return _SizeTransitioningShape.lerp(this, b, t);
  }

  static _SizeTransitioningShape lerp(
      ShapeBorder? a, ShapeBorder? b, double t) {
    assert(t != null);
    assert(a is _SizeTransitioningShape ||
        b is _SizeTransitioningShape); // Not really necessary, but all call sites currently intend this.
    return _SizeTransitioningShape(a, b, t);
  }

  Matrix4 _transformForA(Rect rect) {
    final t = lerpDouble(0.5, 1, 1 - this.t)!;
    final newSize = rect.size * t;
    final dt = (rect.size.bottomRight(Offset.zero) -
            newSize.bottomRight(Offset.zero)) /
        2;
    final start = rect.topLeft + dt;

    return Matrix4.identity()
      ..translate(
        start.dx,
        start.dy,
      )
      ..scale(t);
  }

  Matrix4 _transformForB(Rect rect) {
    final t = lerpDouble(0.5, 1, this.t)!;
    final newSize = rect.size * t;
    final dt = (rect.size.bottomRight(Offset.zero) -
            newSize.bottomRight(Offset.zero)) /
        2;
    final start = rect.topLeft + dt;

    return Matrix4.identity()
      ..translate(
        start.dx,
        start.dy,
      )
      ..scale(t);
  }

  Path? _combinePaths(Path? a, Path? b) {
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    return Path.combine(
      PathOperation.union,
      a,
      b,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final aPath = a
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForA(rect).storage),
        bPath = (b
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForB(rect).storage));
    return _combinePaths(aPath, bPath)!;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final aPath = a
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForA(rect).storage),
        bPath = b
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForB(rect).storage);
    return _combinePaths(aPath, bPath) ?? (Path()..addRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (a != null) {
      canvas.save();
      canvas.transform((_transformForA(rect)).storage);
      a!.paint(canvas, rect, textDirection: textDirection);
      canvas.restore();
    }
    if (b != null) {
      canvas.save();
      canvas.transform((_transformForB(rect)).storage);
      b!.paint(canvas, rect, textDirection: textDirection);
      canvas.restore();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _SizeTransitioningShape &&
        listEquals<ShapeBorder?>(other.borders, borders) &&
        t == other.t;
  }

  @override
  int get hashCode => hashList(borders);

  @override
  String toString() {
    // We list them in reverse order because when adding two borders they end up
    // in the list in the opposite order of what the source looks like: a + b =>
    // [b, a]. We do this to make the painting code more optimal, and most of
    // the rest of the code doesn't care, except toString() (for debugging).
    return nonNullBorders
            .toList()
            .reversed
            .map<String>((ShapeBorder border) => border.toString())
            .join(' + ') +
        '($t)';
  }
}

/// Represents the addition of two otherwise-incompatible borders.
///
/// The borders are listed from the outside to the inside.
class _PathIntersectioningShape extends ShapeBorder {
  _PathIntersectioningShape(this.a, this.b, this.t);
  final ShapeBorder? a;
  final ShapeBorder? b;
  final double t;
  List<ShapeBorder?> get borders => [a, b];
  Iterable<ShapeBorder> get nonNullBorders =>
      borders.where((e) => e != null).cast();

  @override
  EdgeInsetsGeometry get dimensions {
    return nonNullBorders.fold<EdgeInsetsGeometry>(
      EdgeInsets.zero,
      (EdgeInsetsGeometry previousValue, ShapeBorder border) {
        return previousValue.add(border.dimensions);
      },
    );
  }

  @override
  ShapeBorder add(ShapeBorder other, {bool reversed = false}) {
    if (reversed) {
      return _PathIntersectioningShape(other, this, t);
    }
    return _PathIntersectioningShape(this, other, t);
  }

  @override
  ShapeBorder scale(double t) {
    return _PathIntersectioningShape(
      a?.scale(t),
      b?.scale(t),
      this.t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    return _PathIntersectioningShape.lerp(a, this, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    return _PathIntersectioningShape.lerp(this, b, t);
  }

  static _PathIntersectioningShape lerp(
      ShapeBorder? a, ShapeBorder? b, double t) {
    assert(t != null);
    assert(a is _PathIntersectioningShape ||
        b is _PathIntersectioningShape); // Not really necessary, but all call sites currently intend this.
    return _PathIntersectioningShape(a, b, t);
  }

  static final aTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 1 / 2),
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 2.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 1 / 2),
  ]);
  static final bTween = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 2.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 1 / 2),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 1 / 2),
  ]);

  Matrix4 _transformForA(Rect rect) {
    final t = aTween.transform(this.t);
    final newSize = rect.size * t;
    final dt = (rect.size.bottomRight(Offset.zero) -
            newSize.bottomRight(Offset.zero)) /
        2;
    final start = rect.topLeft + dt;

    return Matrix4.identity()
      ..translate(
        start.dx,
        start.dy,
      )
      ..scale(t);
  }

  Matrix4 _transformForB(Rect rect) {
    final t = bTween.transform(this.t);
    final newSize = rect.size * t;
    final dt = (rect.size.bottomRight(Offset.zero) -
            newSize.bottomRight(Offset.zero)) /
        2;
    final start = rect.topLeft + dt;

    return Matrix4.identity()
      ..translate(
        start.dx,
        start.dy,
      )
      ..scale(t);
  }

  Path? _combinePaths(Path? a, Path? b) {
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    return Path.combine(
      PathOperation.intersect,
      a,
      b,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final aPath = a
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForA(rect).storage),
        bPath = (b
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForB(rect).storage));
    return _combinePaths(aPath, bPath)!;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final aPath = a
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForA(rect).storage),
        bPath = b
            ?.getOuterPath(rect, textDirection: textDirection)
            .transform(_transformForB(rect).storage);
    return _combinePaths(aPath, bPath) ?? (Path()..addRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (a != null) {
      canvas.save();
      canvas.transform((_transformForA(rect)).storage);
      a!.paint(canvas, rect, textDirection: textDirection);
      canvas.restore();
    }
    if (b != null) {
      canvas.save();
      canvas.transform((_transformForB(rect)).storage);
      b!.paint(canvas, rect, textDirection: textDirection);
      canvas.restore();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _PathIntersectioningShape &&
        listEquals<ShapeBorder?>(other.borders, borders) &&
        t == other.t;
  }

  @override
  int get hashCode => hashList(borders);

  @override
  String toString() {
    // We list them in reverse order because when adding two borders they end up
    // in the list in the opposite order of what the source looks like: a + b =>
    // [b, a]. We do this to make the painting code more optimal, and most of
    // the rest of the code doesn't care, except toString() (for debugging).
    return nonNullBorders
            .toList()
            .reversed
            .map<String>((ShapeBorder border) => border.toString())
            .join(' + ') +
        '($t)';
  }
}
