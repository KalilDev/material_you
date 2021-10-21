import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

const Duration _kUnconfirmedSplashDuration = Duration(seconds: 1);
const Duration _kSplashFadeDuration = Duration(milliseconds: 200);

const double _kSplashInitialSize = 0.0; // logical pixels
const double _kSplashConfirmedVelocity = 1.0; // logical pixels per millisecond

RectCallback? _getClipCallback(
    RenderBox referenceBox, bool containedInkWell, RectCallback? rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) return () => Offset.zero & referenceBox.size;
  return null;
}

double _getTargetRadius(RenderBox referenceBox, bool containedInkWell,
    RectCallback? rectCallback, Offset position) {
  if (containedInkWell) {
    final Size size =
        rectCallback != null ? rectCallback().size : referenceBox.size;
    return _getSplashRadiusForPositionInSize(size, position);
  }
  return Material.defaultSplashRadius;
}

double _getSplashRadiusForPositionInSize(Size bounds, Offset position) {
  final double d1 = (position - bounds.topLeft(Offset.zero)).distance;
  final double d2 = (position - bounds.topRight(Offset.zero)).distance;
  final double d3 = (position - bounds.bottomLeft(Offset.zero)).distance;
  final double d4 = (position - bounds.bottomRight(Offset.zero)).distance;
  return math.max(math.max(d1, d2), math.max(d3, d4)).ceilToDouble();
}

class _MaterialYouInkSplashFactory extends InteractiveInkFeatureFactory {
  const _MaterialYouInkSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return MaterialYouInkSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

class _SplashParameters {}

/// A visual reaction on a piece of [Material] to user input.
///
/// A circular ink feature whose origin starts at the input touch point
/// and whose radius expands from zero.
///
/// This object is rarely created directly. Instead of creating an ink splash
/// directly, consider using an [InkResponse] or [InkWell] widget, which uses
/// gestures (such as tap and long-press) to trigger ink splashes.
///
/// See also:
///
///  * [InkRipple], which is an ink splash feature that expands more
///    aggressively than this class does.
///  * [InkResponse], which uses gestures to trigger ink highlights and ink
///    splashes in the parent [Material].
///  * [InkWell], which is a rectangular [InkResponse] (the most common type of
///    ink response).
///  * [Material], which is the widget on which the ink splash is painted.
///  * [InkHighlight], which is an ink feature that emphasizes a part of a
///    [Material].
///  * [Ink], a convenience widget for drawing images and other decorations on
///    Material widgets.
class MaterialYouInkSplash extends InteractiveInkFeature {
  /// Begin a splash, centered at position relative to [referenceBox].
  ///
  /// The [controller] argument is typically obtained via
  /// `Material.of(context)`.
  ///
  /// If `containedInkWell` is true, then the splash will be sized to fit
  /// the well rectangle, then clipped to it when drawn. The well
  /// rectangle is the box returned by `rectCallback`, if provided, or
  /// otherwise is the bounds of the [referenceBox].
  ///
  /// If `containedInkWell` is false, then `rectCallback` should be null.
  /// The ink splash is clipped only to the edges of the [Material].
  /// This is the default.
  ///
  /// When the splash is removed, `onRemoved` will be called.
  MaterialYouInkSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required TextDirection textDirection,
    Offset? position,
    required Color color,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  })  : assert(textDirection != null),
        _position = position,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _targetRadius = radius ??
            _getTargetRadius(
                referenceBox, containedInkWell, rectCallback, position!),
        _clipCallback =
            _getClipCallback(referenceBox, containedInkWell, rectCallback),
        _repositionToReferenceBox = !containedInkWell,
        _textDirection = textDirection,
        super(
            controller: controller,
            referenceBox: referenceBox,
            color: color,
            onRemoved: onRemoved) {
    assert(_borderRadius != null);
    _tick = _kUnconfirmedSplashDuration ~/ 6;
    /*Duration(
        milliseconds:
            ((_kInnerCircleRadius * 2) / _kUnconfirmedSplashDuration).floor());*/
    _innerCircleController =
        AnimationController(duration: _tick, vsync: controller.vsync)
          ..addListener(controller.markNeedsPaint)
          ..addStatusListener(_onInnerCircleTick)
          ..repeat(reverse: true);
    _alphaController = AnimationController(
        duration: _kSplashFadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);
    _alpha = _alphaController!.drive(IntTween(
      begin: color.alpha,
      end: 0,
    ));

    controller.addInkFeature(this);
  }

  final Offset? _position;
  final BorderRadius _borderRadius;
  final ShapeBorder? _customBorder;
  final double _targetRadius;
  final RectCallback? _clipCallback;
  final bool _repositionToReferenceBox;
  final TextDirection _textDirection;

  late Duration _tick;

  late Animation<int> _alpha;
  AnimationController? _alphaController;
  AnimationController? _innerCircleController;

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse],
  /// material [Theme], or [ButtonStyle].
  static const InteractiveInkFeatureFactory splashFactory =
      _MaterialYouInkSplashFactory();

  void _dismissRipples() {
    for (final ripple in _rippleControllers) {
      final int duration = (_targetRadius / _kSplashConfirmedVelocity).floor();
      ripple.controller
        ..duration = Duration(milliseconds: duration)
        ..forward();
    }
  }

  double get _kInnerCircleRadius =>
      _kInnerCircleSizeForContainer(referenceBox.size);

  void _dismissInnerCircle() {
    final int duration =
        (_kInnerCircleRadius * 2 / _kSplashConfirmedVelocity).floor();
    _innerCircleController!.reverse();
    _alphaController!.forward();
  }

  @override
  void confirm() {
    _dismissInnerCircle();
    _dismissRipples();
  }

  @override
  void cancel() {
    _alphaController?.forward();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) dispose();
  }

  @override
  void dispose() {
    _alphaController!.dispose();
    _alphaController = null;
    _innerCircleController!.dispose();
    for (final ripple in _rippleControllers) {
      ripple.controller.dispose();
    }
    _rippleControllers.clear();
    super.dispose();
  }

  static const _kBorderWidth = 70.0;
  static double _kSigmaForContainer(Size size) {
    final diagonalSquared = size.height * size.height + size.width * size.width;
    final logPart = math.log(diagonalSquared);
    const inverseK = 5.0;
    final inversePart = (1 / diagonalSquared) * inverseK;
    return logPart - inversePart;
  }

  static double _kInnerCircleSizeForContainer(Size size) {
    final diagonalSquared = size.height * size.height + size.width * size.width;
    const logK = 2.0;
    final logPart = math.log(diagonalSquared) * logK;
    const inverseK = 50000.0;
    final inversePart = (1 / diagonalSquared) * inverseK;
    final result = (logPart - inversePart).clamp(1.0, 24.0);

    print([logPart, inversePart, result]);
    return result;
  }

  ShapeBorder _getShape() {
    if (_customBorder != null) {
      return _customBorder!;
    }

    return RoundedRectangleBorder(borderRadius: _borderRadius);
  }

  late final shape = _getShape();
  final kOverglowWidth = 4.0;
  final kInnerCircleRadius = 18.0;
  final kInnerCircleStrokeWidth = 1.0;
  final kRippleStrokeWidth = 2.0;

  final _innerColor = Colors.black;

  int _rippleI = 0;
  Duration get rippleDuration => Duration(
        milliseconds: (_targetRadius / _kSplashConfirmedVelocity).floor(),
      );
  void _addNewRipple() {
    final animController = AnimationController(
      vsync: controller.vsync,
      duration: _kUnconfirmedSplashDuration,
    )..addListener(controller.markNeedsPaint);
    if (_rippleI > 3) {
      return;
    }
    final rippleController = _RippleController(animController, _rippleI++);

    void maybeDisposeRipple(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        animController.dispose();
        _rippleControllers.remove(rippleController);
      }
    }

    animController
      ..addStatusListener(maybeDisposeRipple)
      ..forward();

    _rippleControllers.add(rippleController);
  }

  void _onInnerCircleTick(AnimationStatus status) {
    if (status != AnimationStatus.forward) {
      return;
    }
    _addNewRipple();
  }

  final List<_RippleController> _rippleControllers = [];
  List<_Ripple> get _ripples => _rippleControllers
      .map((e) => _Ripple(
            e.value,
            _targetRadius,
            e.value * 1.3,
            e.color,
          ))
      .toList();

  void paintBlurred(Canvas canvas, Matrix4 transform) {
    final size = referenceBox.size;
    final center = _position ?? size.center(Offset.zero);
    canvas.save();
    canvas.transform(transform.storage);
    _RipplePainter.paintRipples(
      canvas,
      size,
      center: center,
      shape: shape,
      ripples: _ripples,
      strokeWidth: kRippleStrokeWidth,
    );
    _RipplePainter.paintInnerCircle(
      canvas,
      size,
      color: _innerColor.withAlpha(_alpha.value),
      strokeWidth: kInnerCircleStrokeWidth,
      radius: _innerCircleController!.value * kInnerCircleRadius,
      center: center,
    );
    canvas.restore();
  }

  ImageFilterLayer? _blurLayer;
  ClipPathLayer? _clipLayer;
  @override
  void paint(PaintingContext context, Offset offset) {
    final transform = getTransformToReferenceBox();
    final sigma = _kSigmaForContainer(referenceBox.size);
    _blurLayer = ImageFilterLayer(
        imageFilter: ui.ImageFilter.blur(
      sigmaX: sigma,
      sigmaY: sigma,
    ));
    _clipLayer = ClipPathLayer(
      clipPath: shape.getInnerPath(offset & referenceBox.size),
    );

    context.pushLayer(
        _clipLayer!,
        (context, offset) => context.pushLayer(
              _blurLayer!,
              (context, offset) => paintBlurred(
                context.canvas,
                transform..translate(offset.dx, offset.dy),
              ),
              offset,
            ),
        offset);
  }
}

class _Ripples extends StatefulWidget {
  final Offset position;
  final RenderBox referenceBox;
  final ShapeBorder shape;
  final double targetRadius;

  const _Ripples({
    Key? key,
    required this.position,
    required this.referenceBox,
    required this.shape,
    required this.targetRadius,
  }) : super(key: key);
  @override
  __RipplesState createState() => __RipplesState();
}

class __RipplesState extends State<_Ripples> with TickerProviderStateMixin {
  final _kTick = Duration(milliseconds: 200);
  final kOverglowWidth = 4.0;
  final kInnerCircleRadius = 18.0;
  final kInnerCircleStrokeWidth = 1.0;
  final kRippleStrokeWidth = 2.0;

  late final heartbeat = AnimationController(
    vsync: this,
    duration: _kTick,
  )..addStatusListener(_heartbeatStatusListener);
  Set<_RippleController> rippleControllers = {};
  int _animationI = 0;
  void _heartbeatStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationStep(++_animationI);
      heartbeat.forward(from: 0);
    }
  }

  late final overglowController =
      AnimationController(vsync: this, duration: _kTick);
  late final Animation<double> overglow =
      CurveTween(curve: Curves.linear).animate(overglowController);
  late final AnimationController innerCircleController =
      AnimationController(vsync: this, duration: _kTick * 2);
  late final Animation<Color?> innerCircleColor =
      innerCircleColorTween.animate(innerCircleColorController);
  late final AnimationController innerCircleColorController =
      AnimationController(vsync: this, duration: _kTick * 2 * 4);
  late final Animation<double> innerCircle =
      innerCircleTween.animate(innerCircleController);
  static final innerCircleColorTween = ColorTween(
    begin: Color(0xFFFFFFFF),
    end: Color(0x00FFFFFF),
  );
  static final innerCircleTween = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1 / 2),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1 / 2),
  ]);

  void initAnimation() {
    innerCircleController.repeat();
    innerCircleColorController.forward();
    _addNewRipple();
  }

  double get radialVelocityPerTick => kInnerCircleRadius;
  Duration get rippleDuration =>
      _kTick * (_rippleRadius / radialVelocityPerTick);
  final kRippleRadiusFactor = 1.3;
  double get _rippleRadius => widget.targetRadius * kRippleRadiusFactor;
  int _rippleI = 0;
  void _addNewRipple() {
    final controller = AnimationController(
      vsync: this,
      duration: rippleDuration,
    );
    final rippleController = _RippleController(controller, _rippleI++);

    void disposeRipple(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        rippleControllers.remove(rippleController);
        //paintOverglow = true;
      }
    }

    controller
      ..addStatusListener(disposeRipple)
      ..forward();

    rippleControllers.add(rippleController);
  }

  void animationStep(int i) {
    if (i.isEven) {
      _addNewRipple();
    }
    if (i == 1) {
      overglowController.forward();
      //controllers.add(controller);
    }
  }

  void initState() {
    //animationStep(0);
    heartbeat.forward();
    initAnimation();
    super.initState();
  }

  void dispose() {
    heartbeat.dispose();
    overglowController.dispose();
    innerCircleController.dispose();
    innerCircleColorController.dispose();
    rippleControllers.forEach((e) => e.controller.dispose());
    super.dispose();
  }

  bool paintOverglow = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    /*
    return AnimatedBuilder(
      animation: heartbeat,
      builder: (_, __) => CustomPaint(
        painter: _RipplePainter(
          paintOverglow ? kOverglowWidth : 0, //overglow.value * kOverglowWidth,
          widget.shape,
          kInnerCircleRadius,
          innerCircle.value,
          kInnerCircleStrokeWidth,
          innerCircleColor.value!,
          widget.position,
          rippleControllers
              //.map(rippleCurve.transform)
              .map((e) => _Ripple(
                    e.value,
                    e.value * _rippleRadius,
                    e.value * kRippleRadiusFactor,
                    e.color,
                  ))
              .toList(),
          kRippleStrokeWidth,
        ),
        child: SizedBox.expand(),
      ),
    );*/
  }
}

class _RippleController {
  final AnimationController controller;
  final int index;
  double get value => controller.value;

  _RippleController(this.controller, this.index);
  late final Color color = _computeColor(index);
  static Color _computeColor(int i) {
    if (i >= 3) {
      return Color(0x00FFFFFF);
    }
    return Color(0xff000000).withAlpha([
      255,
      130,
      60,
    ][i]);
  }
}

class _Ripple {
  final double t;
  final double radius;
  final double radiusT;
  final Color color;

  _Ripple(this.t, this.radius, this.radiusT, this.color);
}

abstract class _RipplePainter extends CustomPainter {
  final double overglowWidth;
  final ShapeBorder shape;
  final double innerCircleRadius;
  final double innerCircleT;
  final double innerCircleStrokeWidth;
  final Color innerCircleColor;
  final Offset position;
  final List<_Ripple> ripples;
  final double rippleStrokeWidth;

  _RipplePainter(
    this.overglowWidth,
    this.shape,
    this.innerCircleRadius,
    this.innerCircleT,
    this.innerCircleStrokeWidth,
    this.innerCircleColor,
    this.position,
    this.ripples,
    this.rippleStrokeWidth,
  );

  static void paintInnerCircle(
    Canvas canvas,
    Size size, {
    required Color color,
    required double strokeWidth,
    required double radius,
    required Offset center,
  }) {
    final paint = Paint()..color = color;
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    radius = (radius - (strokeWidth / 2)).clamp(0.0, double.infinity);

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  bool hitTest(Offset a) => false;

  static double _maxOrFinite(double a, double b) => a.isInfinite
      ? b
      : b.isInfinite
          ? a
          : math.max(a, b);

  static double _minOrFinite(double a, double b) => a.isInfinite
      ? b
      : b.isInfinite
          ? a
          : math.min(a, b);

  static const kDistanceFromBorder = 4.0;
  static Rect intersectRect(Rect a, Rect b) => Rect.fromLTRB(
        _maxOrFinite(a.left, b.left),
        _maxOrFinite(a.top, b.top),
        _minOrFinite(a.right, b.right),
        _minOrFinite(a.bottom, b.bottom),
      );
  // Creates an transform which makes the [object] fit in the [target] box
  static Matrix4 transformToFit(Rect object, Rect target) {
    final mat = Matrix4.identity();
    {
      final o = object.topLeft;
      final t = target.topLeft;
      final dt = t - o;
      mat.translate(dt.dx, dt.dy);
    }
    mat.scale(
      object.width == 0 ? 1.0 : (target.width / object.width).clamp(0.0, 1.0),
      object.height == 0
          ? 1.0
          : (target.height / object.height).clamp(0.0, 1.0),
    );

    return mat;
  }

  static double _shortestDelta(Offset dt) => math.min(dt.dx, dt.dy);
  static double _shortestPointToEdge(Offset center, Rect viewRect) => math.min(
        _shortestDelta(center - viewRect.topLeft),
        _shortestDelta(viewRect.bottomRight - center),
      );

  static Path createPathForRipple({
    required Path shape,
    required _Ripple ripple,
    required Offset center,
    required Rect viewRect,
  }) {
    // Deflate the viewRect by a factor proportional to the [t], so that the
    // ripple does not touch the edge until the end, when it is dissipating.
    var distanceFromBorder = _shortestPointToEdge(center, viewRect) - 24.0;
    distanceFromBorder =
        distanceFromBorder.clamp(0.0, (1 - ripple.t) * kDistanceFromBorder);
    final paddedViewRect = viewRect.deflate(distanceFromBorder);

    final circleRect = Rect.fromCircle(
      center: center,
      radius: ripple.radius * ripple.radiusT,
    );
    final circlePath = Path()..addArc(circleRect, 0, 2 * math.pi);

    // Calc the intersection of the circle to the view, and the rect it should
    // occupy for it to fit in the [paddedViewRect]
    final circleViewIntersection = intersectRect(circleRect, viewRect);
    final targetCirceRect =
        intersectRect(circleViewIntersection, paddedViewRect);

    // Create the intersection path between the edge shape and the circle
    var path = Path.combine(PathOperation.intersect, shape, circlePath);

    if (ripple.radiusT <= 1) {
      // Transform the path so that it occupies [targetCircleRect], not
      // touching the border
      path = path.transform(
          transformToFit(circleViewIntersection, targetCirceRect).storage);
    } else {
      // Transform the path so that it expands outwards from the center,
      // leaving the view smoothly
      final dt = ripple.radiusT - 1;
      final dx = viewRect.width * dt / 2, dy = viewRect.height * dt / 2;
      final mat = (Matrix4.identity()
        ..translate(-dx, -dy)
        ..scale(ripple.radiusT));
      path = path.transform(mat.storage);
    }

    return path;
  }

  static void paintRipples(
    Canvas canvas,
    Size size, {
    required List<_Ripple> ripples,
    required ShapeBorder shape,
    required double strokeWidth,
    required Offset center,
  }) {
    final paint = Paint()
      ..color = Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final viewRect = Offset.zero & size;
    final shapePath = shape.getInnerPath(viewRect);
    for (final ripple in ripples) {
      paint..color = ripple.color;
      final path = createPathForRipple(
        shape: shapePath,
        ripple: ripple,
        center: center,
        viewRect: viewRect,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
