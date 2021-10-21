part of 'morphable_path.dart';

double _mapX(Matrix4 transform, double x, double y) =>
    transform.storage[0] * x + transform.storage[4] * y + transform.storage[12];

double _mapY(Matrix4 transform, double x, double y) =>
    transform.storage[1] * x + transform.storage[5] * y + transform.storage[13];

const double _twoPiFloat = math.pi * 2;
const double _piOverTwoFloat = math.pi / 2;

class _Arc {
  final double rx, ry;
  final double rotation;
  final double x, y;
  final bool sweep, largeArc;

  _Arc({
    required this.rx,
    required this.ry,
    required this.rotation,
    required this.x,
    required this.y,
    required this.sweep,
    required this.largeArc,
  });
}

// This works by converting the SVG arc to "simple" beziers.
// Partly adapted from Niko's code in kdelibs/kdecore/svgicons.
// See also SVG implementation notes:
// http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
List<_Cubic> arcToCubics(
  double currentX,
  double currentY,
  _Arc arc,
) {
  // If rx = 0 or ry = 0 then this arc is treated as a straight line segment (a
  // "lineto") joining the endpoints.
  // http://www.w3.org/TR/SVG/implnote.html#ArcOutOfRangeParameters
  double rx = arc.rx.abs().toDouble();
  double ry = arc.ry.abs().toDouble();
  if (rx == 0 || ry == 0) {
    return [_Cubic(currentX, currentY, currentX, currentY, arc.x, arc.y)];
  }

  // If the current point and target point for the arc are identical, it should
  // be treated as a zero length path. This ensures continuity in animations.
  if (arc.x == currentX && arc.y == currentY) {
    return [_Cubic(currentX, currentY, currentX, currentY, arc.x, arc.y)];
  }

  final double angle = arc.rotation;

  final double midPointDistanceX = (currentX - arc.x) * 0.5;
  final double midPointDistanceY = (currentY - arc.y) * 0.5;

  final Matrix4 pointTransform = Matrix4.identity();
  pointTransform.rotateZ(-angle);

  final double transformedMidPointX =
      _mapX(pointTransform, midPointDistanceX, midPointDistanceY);

  final double transformedMidPointY =
      _mapY(pointTransform, midPointDistanceX, midPointDistanceY);

  final double squareRx = rx * rx;
  final double squareRy = ry * ry;
  final double squareX = transformedMidPointX * transformedMidPointX;
  final double squareY = transformedMidPointY * transformedMidPointY;

  // Check if the radii are big enough to draw the arc, scale radii if not.
  // http://www.w3.org/TR/SVG/implnote.html#ArcCorrectionOutOfRangeRadii
  final double radiiScale = squareX / squareRx + squareY / squareRy;
  if (radiiScale > 1.0) {
    rx *= math.sqrt(radiiScale);
    ry *= math.sqrt(radiiScale);
  }
  pointTransform.setIdentity();

  pointTransform.scale(1.0 / rx, 1.0 / ry);
  pointTransform.rotateZ(-angle);

  double point1x = _mapX(pointTransform, currentX, currentY);
  double point1y = _mapX(pointTransform, currentX, currentY);
  double point2x = _mapX(pointTransform, arc.x, arc.y);
  double point2y = _mapY(pointTransform, arc.x, arc.y);
  double deltaX = point2x - point1x;
  double deltaY = point2y - point1y;

  final double d = deltaX * deltaX + deltaY * deltaY;
  final double scaleFactorSquared = math.max(1.0 / d - 0.25, 0.0);
  double scaleFactor = math.sqrt(scaleFactorSquared);
  if (!scaleFactor.isFinite) {
    scaleFactor = 0.0;
  }

  if (arc.sweep == arc.largeArc) {
    scaleFactor = -scaleFactor;
  }

  deltaX = deltaX * scaleFactor;
  deltaY = deltaY * scaleFactor;
  final double centerPointX = ((point1x + point2x) * 0.5) - deltaY;
  final double centerPointY = ((point1y + point2y) * 0.5) + deltaX;

  final double theta1 =
      math.atan2(point1y - centerPointY, point1x - centerPointX);
  final double theta2 =
      math.atan2(point2y - centerPointY, point1x - centerPointX);

  double thetaArc = theta2 - theta1;

  if (thetaArc < 0.0 && arc.sweep) {
    thetaArc += _twoPiFloat;
  } else if (thetaArc > 0.0 && !arc.sweep) {
    thetaArc -= _twoPiFloat;
  }

  pointTransform.setIdentity();
  pointTransform.rotateZ(angle);
  pointTransform.scale(rx, ry);

  // Some results of atan2 on some platform implementations are not exact
  // enough. So that we get more cubic curves than expected here. Adding 0.001f
  // reduces the count of segments to the correct count.
  final int segments = (thetaArc / (_piOverTwoFloat + 0.001)).abs().ceil();
  final List<_Cubic> result = [];
  for (int i = 0; i < segments; ++i) {
    final double startTheta = theta1 + i * thetaArc / segments;
    final double endTheta = theta1 + (i + 1) * thetaArc / segments;

    final double t = (8.0 / 6.0) * math.tan(0.25 * (endTheta - startTheta));
    if (!t.isFinite) {
      return [];
    }
    final double sinStartTheta = math.sin(startTheta);
    final double cosStartTheta = math.cos(startTheta);
    final double sinEndTheta = math.sin(endTheta);
    final double cosEndTheta = math.cos(endTheta);

    point1x = cosStartTheta - t * sinStartTheta + centerPointX;
    point1y = sinStartTheta + t * cosStartTheta + centerPointY;
    final double targetPointX = cosEndTheta + centerPointX;
    final double targetPointY = sinEndTheta + centerPointY;
    point2x = targetPointX + t * sinEndTheta;
    point2y = targetPointY - t * cosEndTheta;

    final cubicOperation = _Cubic(
      _mapX(pointTransform, point1x, point1y),
      _mapY(pointTransform, point1x, point1y),
      _mapX(pointTransform, point2x, point2y),
      _mapY(pointTransform, point2x, point2y),
      _mapX(pointTransform, targetPointX, targetPointY),
      _mapY(pointTransform, targetPointX, targetPointY),
    );
    result.add(cubicOperation);
  }
  return result;
}
