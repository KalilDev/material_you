import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'dart:collection';
import 'package:tuple/tuple.dart';
import 'dart:math' as math;
part 'arc_to_cubics.dart';

Iterable<Tuple2<A, B>> zip<A, B>(Iterable<A> a, Iterable<B> b) sync* {
  final ia = a.iterator, ib = b.iterator;
  while (ia.moveNext() && ib.moveNext()) {
    yield Tuple2(ia.current, ib.current);
  }
}

class MaybeIterator<T> implements Iterator<T?> {
  final Iterator<T> base;

  MaybeIterator(this.base);
  T? current = null;
  T? last = null;

  @override
  bool moveNext() {
    if (base.moveNext()) {
      last = current;
      current = base.current;
      return true;
    }
    return false;
  }
}

class MorphablePath implements ui.Path {
  final List<_Action> _actions;
  final Queue<int> _moveIndices;
  ui.Offset? _currentPoint;
  int _subpaths;

  MorphablePath._(
      this._actions, this._moveIndices, this._currentPoint, this._subpaths);
  factory MorphablePath() => MorphablePath._([], Queue(), null, 0);

  static MorphablePath morph(MorphablePath a, MorphablePath b, double t) {
    if (a._actions.length == b._actions.length &&
        a._subpaths == b._subpaths &&
        zip(a._actions, b._actions).every(
          (e) => e.item1.runtimeType == e.item2.runtimeType,
        )) {
      // trivial case
      final actions = zip(a._actions, b._actions)
          .map((e) => _lerpAction(e.item1, e.item2, t));
      return MorphablePath._(actions.toList(), a._moveIndices,
          _lerpPoint(a._currentPoint, b._currentPoint, t), a._subpaths);
    }
    if (a._subpaths == b._subpaths) {
      // an semi-trivial case, where we can insert dummy cubics so that it is
      // the first case
      final actions = _padActions(a._actions, b._actions);
      return MorphablePath()
        ..addAll(
          actions.map((action) => _lerpAction(action.item1, action.item2, t)),
        );
    }
    // TODO: Later create an heuristic to insert moves!!
    throw UnimplementedError();
  }

  static Iterable<Tuple2<_Action, _Action>> _padActions(
    Iterable<_Action> a,
    Iterable<_Action> b,
  ) sync* {
    final ia = MaybeIterator(a.iterator), ib = MaybeIterator(b.iterator);
    the_main_while:
    while (ia.moveNext() && ib.moveNext()) {
      var ca = ia.current!, cb = ib.current!;
      if (ca.runtimeType == cb.runtimeType) {
        yield Tuple2(ca, cb);
        continue;
      }
      if (ca is _Move) {
        final pa = ia.last!;
        while (cb is! _Move) {
          yield Tuple2(pa.stationed(), cb);
          if (!ib.moveNext()) {
            // ??????????
            break the_main_while;
          }
          cb = ib.current!;
        }
        yield Tuple2(ca, cb);
      }
      if (cb is _Move) {
        final pb = ib.last!;
        while (ca is! _Move) {
          yield Tuple2(ca, pb.stationed());
          if (!ia.moveNext()) {
            // ??????????
            break the_main_while;
          }
          ca = ia.current!;
        }
        yield Tuple2(ca, cb);
      }
    }
    // a.length > b.length
    while (ia.moveNext()) {
      yield Tuple2(ia.current!, ib.last!.stationed());
    }

    // b.length > a.length
    while (ib.moveNext()) {
      yield Tuple2(ia.last!.stationed(), ib.current!);
    }
  }

  void add(_Action action) {
    if (action is _Move) {
      return moveTo(action.x, action.y);
    }
    final c = action as _Cubic;
    return cubicTo(c.x1, c.y1, c.x2, c.y2, c.x, c.y);
  }

  void addAll(Iterable<_Action> actions) => actions.forEach(add);

  static double _lerp(double a, double b, double t) => a + ((b - a) * t);
  static _Cubic _lerpCubic(_Cubic a, _Cubic b, double t) => _Cubic(
        _lerp(a.x1, b.x1, t),
        _lerp(a.y1, b.y1, t),
        _lerp(a.x2, b.x2, t),
        _lerp(a.y2, b.y2, t),
        _lerp(a.x, b.x, t),
        _lerp(a.y, b.y, t),
      );
  static ui.Offset? _lerpPoint(ui.Offset? a, ui.Offset? b, double t) {
    if (a == null) {
      return t <= 0.5 ? null : b;
    }
    if (b == null) {
      return t > 0.5 ? null : a;
    }
    return ui.Offset(
      _lerp(a.dx, b.dx, t),
      _lerp(a.dy, b.dy, t),
    );
  }

  static _Move _lerpMove(_Move a, _Move b, double t) => _Move(
        _lerp(a.x, b.x, t),
        _lerp(a.y, b.y, t),
      );
  static _Action _lerpAction(_Action a, _Action b, double t) {
    if (a is _Cubic && b is _Cubic) {
      return _lerpCubic(a, b, t);
    }
    if (a is _Move && b is _Move) {
      return _lerpMove(a, b, t);
    }
    throw TypeError();
  }

  @override
  ui.PathFillType fillType = ui.PathFillType.nonZero;

  @override
  void addArc(ui.Rect oval, double startAngle, double sweepAngle) =>
      throw UnimplementedError();

  @override
  void addOval(ui.Rect oval) {
    final dtr = oval.topRight - oval.center;
    final dbr = oval.bottomRight - oval.center;
    final dbl = oval.bottomRight - oval.center;
    final dtl = oval.topLeft - oval.center;
    moveTo(oval.topCenter.dx, oval.topCenter.dy);
    arcToPoint(
      oval.centerRight,
      radius: Radius.elliptical(dtr.dx, dtr.dy),
      rotation: 90,
      largeArc: true,
    );
    arcToPoint(
      oval.bottomCenter,
      radius: Radius.elliptical(dbr.dx, dbr.dy),
      rotation: 90,
      largeArc: true,
    );
    arcToPoint(
      oval.centerLeft,
      radius: Radius.elliptical(dbl.dx, dbl.dy),
      rotation: 90,
      largeArc: true,
    );
    arcToPoint(
      oval.topCenter,
      radius: Radius.elliptical(dtl.dx, dtl.dy),
      rotation: 90,
      largeArc: true,
    );
    close();
  }

  @override
  void addPath(ui.Path path, ui.Offset offset, {Float64List? matrix4}) {
    if (path is! MorphablePath) {
      throw UnimplementedError();
    }
    if (matrix4 != null) {
      if (offset != ui.Offset.zero) {
        matrix4 = Float64List.fromList(matrix4)
          ..[8] = offset.dx
          ..[9] = offset.dy;
      }
      return addPath(path.transform(matrix4), ui.Offset.zero);
    }

    if (offset != ui.Offset.zero) {
      return addPath(path.shift(offset), ui.Offset.zero);
    }

    _actions.addAll(path._actions);
    _moveIndices.addAll(path._moveIndices);
    _subpaths += path._subpaths;
    _currentPoint = path._currentPoint;
    return;
  }

  @override
  void addPolygon(List<ui.Offset> points, bool close) {
    if (points.isEmpty) {
      final c = _currentPoint ?? ui.Offset.zero;
      moveTo(c.dx, c.dy);
      if (close) {
        this.close();
      }
      return;
    }

    final oldCurr = _currentPoint;
    final start = points.first;
    moveTo(start.dx, start.dy);
    for (final p in points.skip(1)) {
      lineTo(p.dx, p.dy);
    }
    if (close) {
      this.close();
      _currentPoint = oldCurr;
    }
  }

  @override
  void addRRect(ui.RRect rrect) {
    if (rrect.isRect) {
      return addRect(Rect.fromLTRB(
        rrect.left,
        rrect.top,
        rrect.right,
        rrect.bottom,
      ));
    }
    final oldCurr = _currentPoint;

    final r = rrect;
    moveTo(r.left + r.tlRadiusX, r.top);
    lineTo(r.right - r.trRadiusX, r.top);
    relativeQuadraticBezierTo(r.trRadiusX, 0, r.trRadiusX, -r.trRadiusY);
    lineTo(r.right, r.bottom - r.brRadiusY);
    relativeQuadraticBezierTo(0, r.brRadiusY, -r.brRadiusX, r.brRadiusY);
    lineTo(r.left + r.brRadiusX, r.bottom);
    relativeQuadraticBezierTo(-r.blRadiusX, 0, -r.blRadiusX, -r.blRadiusY);
    lineTo(r.left, r.top + r.tlRadiusY);
    relativeQuadraticBezierTo(0, -r.tlRadiusY, r.tlRadiusX, -r.tlRadiusY);
    close();

    _currentPoint = oldCurr;
  }

  @override
  void addRect(ui.Rect rect) {
    final oldCurr = _currentPoint;
    final tl = rect.topLeft,
        tr = rect.topRight,
        br = rect.bottomRight,
        bl = rect.bottomLeft;
    moveTo(tl.dx, tl.dy);
    lineTo(tr.dx, tr.dy);
    lineTo(br.dx, br.dy);
    lineTo(bl.dx, bl.dy);
    close();
    _currentPoint = oldCurr;
  }

  @override
  void arcTo(
      ui.Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    throw UnimplementedError();
  }

  @override
  void arcToPoint(ui.Offset arcEnd,
      {ui.Radius radius = Radius.zero,
      double rotation = 0.0,
      bool largeArc = false,
      bool clockwise = true}) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    final arc = _Arc(
      rx: radius.x,
      ry: radius.y,
      rotation: rotation,
      x: arcEnd.dx,
      y: arcEnd.dy,
      sweep: largeArc,
      largeArc: largeArc,
    );
    final cubics = arcToCubics(curr.dx, curr.dy, arc);
    addAll(cubics);
  }

  @override
  void close() {
    if (_moveIndices.isEmpty) {
      return;
    }
    final start = _actions[_moveIndices.removeLast()] as _Move;
    if (_currentPoint?.dx == start.x && _currentPoint?.dy == start.y) {
      return;
    }
    lineTo(start.x, start.y);
  }

  ui.Path _pathFromActions() => _actions.fold(ui.Path(), (p, e) {
        if (e is _Move) {
          return p..moveTo(e.x, e.y);
        }
        final c = e as _Cubic;
        return p..cubicTo(c.x1, c.y1, c.x2, c.y2, c.x, c.y);
      });

  ui.Path toPath() => _pathFromActions();

  @override
  ui.PathMetrics computeMetrics({bool forceClosed = false}) =>
      _pathFromActions().computeMetrics(forceClosed: forceClosed);

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    throw UnimplementedError();
  }

  @override
  bool contains(ui.Offset point) => _pathFromActions().contains(point);

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _maybeAddOriginOrSubpathStart();
    _actions.add(_Cubic(x1, y1, x2, y2, x3, y3));
    _currentPoint = ui.Offset(x3, y3);
  }

  @override
  void extendWithPath(ui.Path path, ui.Offset offset, {Float64List? matrix4}) {
    throw UnimplementedError();
  }

  @override
  ui.Rect getBounds() => _pathFromActions().getBounds();

  void _maybeAddOriginOrSubpathStart() {
    if (_currentPoint != null) {
      /*
      if (_moveIndices.isEmpty) {
        // We are at an open subpath
        return;
      }
      // We are at an closed subpath, so we add an move to start an new subpath
      _moveIndices.add(_actions.length);
      final curr = _currentPoint!;
      _actions.add(_Move(curr.dx, curr.dy));
      _subpaths++;*/
      return;
    }
    _currentPoint = Offset.zero;
    _moveIndices.add(_actions.length);
    _actions.add(_Move.zero);
    _subpaths++;
  }

  @override
  void lineTo(double x, double y) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    final dx = x - curr.dx, dy = y - curr.dy;
    final dxThird = dx / 3, dyThird = dy / 3;

    // CP0 = LP0
    // CP1 = LP0 + 1/3 *(LP1-LP0)
    // CP2 = LP0 + 2/3 *(LP1-LP0)
    // CP3 = LP1
    final cp0 = ui.Offset(
      curr.dx,
      curr.dy,
    );
    final cp1 = ui.Offset(
      curr.dx + dxThird,
      curr.dy + dyThird,
    );
    final cp2_1 = ui.Offset(
      curr.dx + dxThird + dxThird,
      curr.dy + dyThird + dyThird,
    );
    final cp2_2 = ui.Offset(
      x - dxThird,
      y - dyThird,
    );
    final cp3 = ui.Offset(
      x,
      y,
    );
    return cubicTo(
      curr.dx + dxThird,
      curr.dy + dyThird,
      x - dxThird,
      y - dyThird,
      x,
      y,
    );
  }

  @override
  void moveTo(double x, double y) {
    _moveIndices.add(_actions.length);
    _subpaths++;
    _actions.add(_Move(x, y));
    _currentPoint = ui.Offset(x, y);
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    const twoThirds = 2 / 3;
    final dx1 = x1 - curr.dx, dy1 = y1 - curr.dy;
    final dx2 = x1 - x2, dy2 = y1 - y2;
    // CP0 = QP0
    // CP1 = QP0 + 2/3 *(QP1-QP0)
    // CP2 = QP2 + 2/3 *(QP1-QP2)
    // CP3 = QP3
    return cubicTo(
      curr.dx + twoThirds * dx1,
      curr.dy + twoThirds * dy1,
      x2 + twoThirds * dx2,
      y2 + twoThirds * dy2,
      x2,
      y2,
    );
  }

  @override
  void relativeArcToPoint(ui.Offset arcEndDelta,
      {ui.Radius radius = Radius.zero,
      double rotation = 0.0,
      bool largeArc = false,
      bool clockwise = true}) {
    _maybeAddOriginOrSubpathStart();
    arcToPoint(
      _currentPoint! + arcEndDelta,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    return conicTo(
      x1 + curr.dx,
      y1 + curr.dy,
      x2 + curr.dx,
      y2 + curr.dy,
      w,
    );
  }

  @override
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    return cubicTo(
      x1 + curr.dx,
      y1 + curr.dy,
      x2 + curr.dx,
      y2 + curr.dy,
      x3 + curr.dx,
      y3 + curr.dy,
    );
  }

  @override
  void relativeLineTo(double dx, double dy) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    return lineTo(
      dx + curr.dx,
      dy + curr.dy,
    );
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    if (_currentPoint == null) {
      return moveTo(dx, dy);
    }
    final curr = _currentPoint!;
    return moveTo(dx + curr.dx, dy + curr.dy);
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _maybeAddOriginOrSubpathStart();
    final curr = _currentPoint!;
    return quadraticBezierTo(
      x1 + curr.dx,
      y1 + curr.dy,
      x2 + curr.dx,
      y2 + curr.dy,
    );
  }

  @override
  void reset() {
    _actions.clear();
    _moveIndices.clear();
  }

  @override
  MorphablePath shift(ui.Offset offset) => transform(Float64List(16)
    ..[0] = 1
    ..[5] = 1
    ..[10] = 1
    ..[15] = 1
    ..[8] = offset.dx
    ..[9] = offset.dy);

  _Move _transformMove(_Move m, Float64List matrix) {
    return _Move(
      m.x * matrix[0] + m.y * matrix[4] + matrix[8] + matrix[12],
      m.x * matrix[1] + m.y * matrix[5] + matrix[9] + matrix[13],
    );
  }

  ui.Offset _transformPoint(ui.Offset p, Float64List matrix) {
    return ui.Offset(
      p.dx * matrix[0] + p.dy * matrix[4] + matrix[8] + matrix[12],
      p.dx * matrix[1] + p.dy * matrix[5] + matrix[9] + matrix[13],
    );
  }

  _Cubic _transformCubic(_Cubic c, Float64List matrix) {
    return _Cubic(
      c.x1 * matrix[0] + c.y1 * matrix[4] + matrix[8] + matrix[12],
      c.x1 * matrix[1] + c.y1 * matrix[5] + matrix[9] + matrix[13],
      c.x2 * matrix[0] + c.y2 * matrix[4] + matrix[8] + matrix[12],
      c.x2 * matrix[1] + c.y2 * matrix[5] + matrix[9] + matrix[13],
      c.x * matrix[0] + c.y * matrix[4] + matrix[8] + matrix[12],
      c.x * matrix[1] + c.y * matrix[5] + matrix[9] + matrix[13],
    );
  }

  _Action _transformAction(_Action e, Float64List matrix) => e is _Cubic
      ? _transformCubic(e, matrix)
      : _transformMove(e as _Move, matrix);

  @override
  MorphablePath transform(Float64List matrix4) => MorphablePath._(
        _actions.map((e) => _transformAction(e, matrix4)).toList(),
        Queue.from(_moveIndices),
        _currentPoint == null ? null : _transformPoint(_currentPoint!, matrix4),
        _subpaths,
      );
}

abstract class _Action {
  const _Action();

  _Action stationed();
}

class _Move extends _Action {
  final double x, y;

  const _Move(this.x, this.y);

  static const zero = _Move(0, 0);
  _Move stationed() => this;
}

class _Cubic extends _Action {
  final double x1, y1;
  final double x2, y2;
  final double x, y;

  const _Cubic(this.x1, this.y1, this.x2, this.y2, this.x, this.y);
  _Cubic stationed() => _Cubic(x, y, x, y, x, y);
}
