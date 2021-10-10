import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:new_inkwell/collision.dart';

import 'material.dart';
import 'ink_well.dart';
import 'dart:math' as math;

const Duration _kUnconfirmedSplashDuration = Duration(milliseconds: 1000);
const Duration _kSplashFadeDuration = Duration(milliseconds: 300);

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

class _Particle {
  Offset point;
  final Color color;
  final double radius;
  final double opacity;

  _Particle._(
    this.point,
    this.color,
    this.radius,
    this.opacity,
  );
  factory _Particle(
    Offset offset,
    double colorT,
    double radiusT,
    double opacityT,
  ) {
    final radius = lerpDouble(0.5, 1.0, radiusT)! / 2;
    final opacity = lerpDouble(0.3, 0.9, opacityT)! / 2;
    final color = Color.lerp(Colors.white.withAlpha(0), Colors.white, colorT)!
        .withOpacity(opacity);
    return _Particle._(
      offset,
      color,
      radius,
      opacity,
    );
  }
}

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
    _radiusController = AnimationController(
        duration: _kUnconfirmedSplashDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _radius = _radiusController.drive(Tween<double>(
      begin: _kSplashInitialSize,
      end: _targetRadius,
    ));
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

  late Animation<double> _radius;
  late AnimationController _radiusController;

  late Animation<int> _alpha;
  AnimationController? _alphaController;

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse],
  /// material [Theme], or [ButtonStyle].
  static const InteractiveInkFeatureFactory splashFactory =
      _MaterialYouInkSplashFactory();

  @override
  void confirm() {
    final int duration = (_targetRadius / _kSplashConfirmedVelocity).floor();
    _radiusController
      ..duration = Duration(milliseconds: duration)
      ..forward();
    _alphaController!.forward();
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
    _radiusController.dispose();
    _alphaController!.dispose();
    _alphaController = null;
    super.dispose();
  }

  static const _kBorderWidth = 70.0;
  static const _kSigma = 20.0;

  ShapeBorder _getShape() {
    if (_customBorder != null) {
      return _customBorder!;
    }

    return RoundedRectangleBorder(borderRadius: _borderRadius);
  }

  static bool _isZero(Radius r) => r.x == 0.0 && r.y == 0.0;
  Clip _getClipBehavior() {
    if (_customBorder != null) {
      return Clip.antiAlias;
    }
    final br = _borderRadius;
    if (_isZero(br.topLeft) &&
        _isZero(br.topRight) &&
        _isZero(br.bottomLeft) &&
        _isZero(br.bottomRight)) {
      return Clip.hardEdge;
    }
    return Clip.antiAlias;
  }

  @override
  Widget build(BuildContext context) {
    final shape = _getShape();
    return AnimatedBuilder(
      animation: _radius,
      builder: (_, __) {
        final rect = Rect.fromCircle(center: _position!, radius: _radius.value);

        return ClipPath(
          clipBehavior: _getClipBehavior(),
          clipper: ShapeBorderClipper(
            shape: shape,
            textDirection: Directionality.maybeOf(context),
          ),
          child: Stack(children: [
            /*Positioned.fromRect(
                child: ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaX: _kSigma, sigmaY: _kSigma),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: color.withAlpha(_alpha.value),
                          width: _kBorderWidth),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                rect: rect,
              ),*/
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), //4.0
                child: _Ripples(
                  key: ObjectKey(_position),
                  position: _position!,
                  referenceBox: referenceBox,
                  shape: shape,
                  targetRadius: _targetRadius,
                ),
              ),
            ),
          ]),
        );
      },
    );
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
    begin: Colors.white,
    end: Colors.white.withAlpha(0),
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
    return AnimatedBuilder(
      animation: heartbeat,
      builder: (_, __) => CustomPaint(
        painter: RipplePainter(
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
    );
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
      return Colors.transparent;
    }
    return Colors.white.withAlpha([
      255,
      100,
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

class RipplePainter extends CustomPainter {
  final double overglowWidth;
  final ShapeBorder shape;
  final double innerCircleRadius;
  final double innerCircleT;
  final double innerCircleStrokeWidth;
  final Color innerCircleColor;
  final Offset position;
  final List<_Ripple> ripples;
  final double rippleStrokeWidth;

  RipplePainter(
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
  @override
  void paint(Canvas canvas, Size size) {
    _paintRipples(canvas, size);
    _paintOverglow(canvas, size);
    _paintInnerCircle(canvas, size);
  }

  void _paintInnerCircle(Canvas canvas, Size size) {
    final paint = Paint()..color = innerCircleColor;
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerCircleStrokeWidth;

    final radius =
        ((innerCircleRadius * innerCircleT) - (innerCircleStrokeWidth / 2))
            .clamp(0.0, double.infinity);

    canvas.drawCircle(
      position,
      radius,
      paint,
    );
  }

  bool hitTest(Offset a) => false;

  static const kDistanceFromBorder = 4.0;
  static Rect intersectRect(Rect a, Rect b) => Rect.fromLTRB(
        max(a.left, b.left),
        max(a.top, b.top),
        min(a.right, b.right),
        min(a.bottom, b.bottom),
      );
  static Matrix4 transformToFit(Rect object, Rect target) {
    final mat = Matrix4.identity();
    {
      final o = object.topLeft;
      final t = target.topLeft;
      final dt = t - o;
      mat.translate(dt.dx, dt.dy);
    }
    mat.scale(
      target.width / object.width,
      target.height / object.height,
    );

    return mat;
  }

  void _paintRipples(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = rippleStrokeWidth;
    final shapePath = shape.getInnerPath(Offset.zero & size);
    for (final ripple in ripples) {
      paint..color = ripple.color;
      final maxDistanceFromBorder = (1 - ripple.t) * kDistanceFromBorder;
      final paddedView = (Offset.zero & size).deflate(maxDistanceFromBorder);
      final circleRect = Rect.fromCircle(
        center: position,
        radius: ripple.radius,
      );
      final resultRect = intersectRect(circleRect, Offset.zero & size);
      final targetRect = intersectRect(resultRect, paddedView);
      final circlePath = Path()..addArc(circleRect, 0, 2 * pi);
      var path = Path.combine(PathOperation.intersect, shapePath, circlePath);

      if (ripple.radiusT <= 1) {
        path = path.transform(transformToFit(resultRect, targetRect).storage);
      } else {
        final t = ripple.radiusT;
        final dx = size.width * (1 - t) / 2, dy = size.height * (1 - t) / 2;
        final mat = (Matrix4.identity()
          ..translate(dx, dy)
          ..scale(t));
        path = path.transform(mat.storage);
      }
      //canvas.drawCircle(position, ripple, paint);
      canvas.drawPath(path, paint);
    }
  }

  void _paintOverglow(Canvas canvas, Size size) {
    final path = shape.getInnerPath(Offset.zero & size);
    if (overglowWidth == 0) {
      return;
    }
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = overglowWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
