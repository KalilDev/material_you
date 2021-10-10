import 'dart:math';

import 'material.dart';

List<double> _solveQuadratic(double a, double b, double c) {
  final delta = (b * b) - 4 * a * c;
  if (delta < 0) {
    return const [];
  }
  final a2 = 2 * a;
  if (delta == 0.0) {
    return [-b / a2];
  }
  final sqrtDelta = sqrt(delta);
  return [
    (-b + sqrtDelta) / a2,
    (-b - sqrtDelta) / a2,
  ];
}

/// Solve an collision equation in the form of x^2 + y^2 - r^2 = 0 with an fixed
/// x and r
List<Offset> _collideX(double x, Offset center, double r) {
  final x2 = x * x;
  final cx = center.dx, cy = center.dy;
  final cx2 = cx * cx, cy2 = cy * cy;

  final r2 = r * r;

  final xPart = x2 - (2 * x * cx) + cx2;

  final constantPart = xPart + cy2 - r2;
  final a = 1.0, b = -2 * cy;

  final result = _solveQuadratic(a, b, constantPart);
  return result.map((e) => Offset(x, e)).toList();
}

/// Solve an collision equation in the form of x^2 + y^2 - r^2 = 0 with an fixed
/// y and r
List<Offset> _collideY(double y, Offset center, double r) {
  final y2 = y * y;
  final cx = center.dx, cy = center.dy;
  final cx2 = cx * cx, cy2 = cy * cy;

  final r2 = r * r;

  final yPart = y2 - (2 * y * cy) + cy2;

  final constantPart = yPart + cx2 - r2;
  final a = 1.0, b = -2 * cx;

  final result = _solveQuadratic(a, b, constantPart);
  return result.map((e) => Offset(e, y)).toList();
}

List<Offset> collideCircleToRect(Size size, Offset center, double radius) {
  return <Offset>[
    ..._collideX(0, center, radius),
    ..._collideX(size.width, center, radius),
    ..._collideY(0, center, radius),
    ..._collideY(size.height, center, radius),
  ];
}
