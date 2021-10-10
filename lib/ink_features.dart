import 'package:flutter/foundation.dart';
import 'material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart' as flt;

/// An interface for creating [MaterialYouInkSplash]s and [InkHighlight]s on a material.
///
/// Typically obtained via [Material.of].
abstract class MaterialInkController {
  /// The color of the material.
  Color? get color;

  /// The ticker provider used by the controller.
  ///
  /// Ink features that are added to this controller with [addInkFeature] should
  /// use this vsync to drive their animations.
  TickerProvider get vsync;

  /// Add an [InkFeature], such as an [MaterialYouInkSplash] or an [InkHighlight].
  ///
  /// The ink feature will paint as part of this controller.
  void addInkFeature(InkFeature feature);

  /// Notifies the controller that one of its ink features needs to repaint.
  void markNeedsPaint();
}

/// A piece of material.
///
/// The Material widget is responsible for:
///
/// 1. Clipping: If [clipBehavior] is not [Clip.none], Material clips its widget
///    sub-tree to the shape specified by [shape], [type], and [borderRadius].
///    By default, [clipBehavior] is [Clip.none] for performance considerations.
/// 2. Elevation: Material elevates its widget sub-tree on the Z axis by
///    [elevation] pixels, and draws the appropriate shadow.
/// 3. Ink effects: Material shows ink effects implemented by [InkFeature]s
///    like [InkSplash] and [InkHighlight] below its children.
///
/// ## The Material Metaphor
///
/// Material is the central metaphor in material design. Each piece of material
/// exists at a given elevation, which influences how that piece of material
/// visually relates to other pieces of material and how that material casts
/// shadows.
///
/// Most user interface elements are either conceptually printed on a piece of
/// material or themselves made of material. Material reacts to user input using
/// [MaterialYouInkSplash] and [InkHighlight] effects. To trigger a reaction on the
/// material, use a [MaterialInkController] obtained via [Material.of].
///
/// In general, the features of a [Material] should not change over time (e.g. a
/// [Material] should not change its [color], [shadowColor] or [type]).
/// Changes to [elevation] and [shadowColor] are animated for [animationDuration].
/// Changes to [shape] are animated if [type] is not [MaterialType.transparency]
/// and [ShapeBorder.lerp] between the previous and next [shape] values is
/// supported. Shape changes are also animated for [animationDuration].
///
/// ## Shape
///
/// The shape for material is determined by [shape], [type], and [borderRadius].
///
///  - If [shape] is non null, it determines the shape.
///  - If [shape] is null and [borderRadius] is non null, the shape is a
///    rounded rectangle, with corners specified by [borderRadius].
///  - If [shape] and [borderRadius] are null, [type] determines the
///    shape as follows:
///    - [MaterialType.canvas]: the default material shape is a rectangle.
///    - [MaterialType.card]: the default material shape is a rectangle with
///      rounded edges. The edge radii is specified by [kMaterialEdges].
///    - [MaterialType.circle]: the default material shape is a circle.
///    - [MaterialType.button]: the default material shape is a rectangle with
///      rounded edges. The edge radii is specified by [kMaterialEdges].
///    - [MaterialType.transparency]: the default material shape is a rectangle.
///
/// ## Border
///
/// If [shape] is not null, then its border will also be painted (if any).
///
/// ## Layout change notifications
///
/// If the layout changes (e.g. because there's a list on the material, and it's
/// been scrolled), a [LayoutChangedNotification] must be dispatched at the
/// relevant subtree. This in particular means that transitions (e.g.
/// [SlideTransition]) should not be placed inside [Material] widgets so as to
/// move subtrees that contain [InkResponse]s, [InkWell]s, [Ink]s, or other
/// widgets that use the [InkFeature] mechanism. Otherwise, in-progress ink
/// features (e.g., ink splashes and ink highlights) won't move to account for
/// the new layout.
///
/// ## Painting over the material
///
/// Material widgets will often trigger reactions on their nearest material
/// ancestor. For example, [ListTile.hoverColor] triggers a reaction on the
/// tile's material when a pointer is hovering over it. These reactions will be
/// obscured if any widget in between them and the material paints in such a
/// way as to obscure the material (such as setting a [BoxDecoration.color] on
/// a [DecoratedBox]). To avoid this behavior, use [InkDecoration] to decorate
/// the material itself.
///
/// See also:
///
///  * [MergeableMaterial], a piece of material that can split and re-merge.
///  * [Card], a wrapper for a [Material] of [type] [MaterialType.card].
///  * <https://material.io/design/>
class Material extends StatefulWidget {
  /// Creates a piece of material.
  ///
  /// The [type], [elevation], [shadowColor], [borderOnForeground],
  /// [clipBehavior], and [animationDuration] arguments must not be null.
  /// Additionally, [elevation] must be non-negative.
  ///
  /// If a [shape] is specified, then the [borderRadius] property must be
  /// null and the [type] property must not be [MaterialType.circle]. If the
  /// [borderRadius] is specified, then the [type] property must not be
  /// [MaterialType.circle]. In both cases, these restrictions are intended to
  /// catch likely errors.
  const Material({
    Key? key,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color,
    this.shadowColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.animationDuration = kThemeChangeDuration,
    this.child,
  })  : assert(type != null),
        assert(elevation != null && elevation >= 0.0),
        assert(!(shape != null && borderRadius != null)),
        assert(animationDuration != null),
        assert(!(identical(type, MaterialType.circle) &&
            (borderRadius != null || shape != null))),
        assert(borderOnForeground != null),
        assert(clipBehavior != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The kind of material to show (e.g., card or canvas). This
  /// affects the shape of the widget, the roundness of its corners if
  /// the shape is rectangular, and the default color.
  final MaterialType type;

  /// {@template flutter.material.material.elevation}
  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material and the opacity
  /// of the elevation overlay color if it is applied.
  ///
  /// If this is non-zero, the contents of the material are clipped, because the
  /// widget conceptually defines an independent printed piece of material.
  ///
  /// Defaults to 0. Changing this value will cause the shadow and the elevation
  /// overlay to animate over [Material.animationDuration].
  ///
  /// The value is non-negative.
  ///
  /// See also:
  ///
  ///  * [ThemeData.applyElevationOverlayColor] which controls the whether
  ///    an overlay color will be applied to indicate elevation.
  ///  * [Material.color] which may have an elevation overlay applied.
  ///
  /// {@endtemplate}
  final double elevation;

  /// The color to paint the material.
  ///
  /// Must be opaque. To create a transparent piece of material, use
  /// [MaterialType.transparency].
  ///
  /// To support dark themes, if the surrounding
  /// [ThemeData.applyElevationOverlayColor] is true and [ThemeData.brightness]
  /// is [Brightness.dark] then a semi-transparent overlay color will be
  /// composited on top of this color to indicate the elevation.
  ///
  /// By default, the color is derived from the [type] of material.
  final Color? color;

  /// The color to paint the shadow below the material.
  ///
  /// If null, [ThemeData.shadowColor] is used, which defaults to fully opaque black.
  ///
  /// Shadows can be difficult to see in a dark theme, so the elevation of a
  /// surface should be portrayed with an "overlay" in addition to the shadow.
  /// As the elevation of the component increases, the overlay increases in
  /// opacity.
  ///
  /// See also:
  ///
  ///  * [ThemeData.applyElevationOverlayColor], which turns elevation overlay
  /// on or off for dark themes.
  final Color? shadowColor;

  /// The typographical style to use for text within this material.
  final TextStyle? textStyle;

  /// Defines the material's shape as well its shadow.
  ///
  /// If shape is non null, the [borderRadius] is ignored and the material's
  /// clip boundary and shadow are defined by the shape.
  ///
  /// A shadow is only displayed if the [elevation] is greater than
  /// zero.
  final ShapeBorder? shape;

  /// Whether to paint the [shape] border in front of the [child].
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the [child].
  final bool borderOnForeground;

  /// {@template flutter.material.Material.clipBehavior}
  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  /// {@endtemplate}
  ///
  /// Defaults to [Clip.none], and must not be null.
  final Clip clipBehavior;

  /// Defines the duration of animated changes for [shape], [elevation],
  /// [shadowColor] and the elevation overlay if it is applied.
  ///
  /// The default value is [kThemeChangeDuration].
  final Duration animationDuration;

  /// If non-null, the corners of this box are rounded by this
  /// [BorderRadiusGeometry] value.
  ///
  /// Otherwise, the corners specified for the current [type] of material are
  /// used.
  ///
  /// If [shape] is non null then the border radius is ignored.
  ///
  /// Must be null if [type] is [MaterialType.circle].
  final BorderRadiusGeometry? borderRadius;

  /// The ink controller from the closest instance of this class that
  /// encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// MaterialInkController inkController = Material.of(context);
  /// ```
  static MaterialInkController? of(BuildContext context) {
    return context.findAncestorStateOfType<_InkFeaturesContainerState>();
  }

  @override
  _MaterialState createState() => _MaterialState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<MaterialType>('type', type));
    properties.add(DoubleProperty('elevation', elevation, defaultValue: 0.0));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties
        .add(ColorProperty('shadowColor', shadowColor, defaultValue: null));
    textStyle?.debugFillProperties(properties, prefix: 'textStyle.');
    properties.add(
        DiagnosticsProperty<ShapeBorder>('shape', shape, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>(
        'borderOnForeground', borderOnForeground,
        defaultValue: true));
    properties.add(DiagnosticsProperty<BorderRadiusGeometry>(
        'borderRadius', borderRadius,
        defaultValue: null));
  }

  /// The default radius of an ink splash in logical pixels.
  static const double defaultSplashRadius = 35.0;
}

/// The interior of non-transparent material.
///
/// Animates [elevation], [shadowColor], and [shape].
class _MaterialInterior extends ImplicitlyAnimatedWidget {
  /// Creates a const instance of [_MaterialInterior].
  ///
  /// The [child], [shape], [clipBehavior], [color], and [shadowColor] arguments
  /// must not be null. The [elevation] must be specified and greater than or
  /// equal to zero.
  const _MaterialInterior({
    Key? key,
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    required this.elevation,
    required this.color,
    required this.shadowColor,
    Curve curve = Curves.linear,
    required Duration duration,
  })  : assert(child != null),
        assert(shape != null),
        assert(clipBehavior != null),
        assert(elevation != null && elevation >= 0.0),
        assert(color != null),
        assert(shadowColor != null),
        super(key: key, curve: curve, duration: duration);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The border of the widget.
  ///
  /// This border will be painted, and in addition the outer path of the border
  /// determines the physical shape.
  final ShapeBorder shape;

  /// Whether to paint the border in front of the child.
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the child.
  final bool borderOnForeground;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none], and must not be null.
  final Clip clipBehavior;

  /// The target z-coordinate at which to place this physical object relative
  /// to its parent.
  ///
  /// The value is non-negative.
  final double elevation;

  /// The target background color.
  final Color color;

  /// The target shadow color.
  final Color shadowColor;

  @override
  _MaterialInteriorState createState() => _MaterialInteriorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
    description.add(DoubleProperty('elevation', elevation));
    description.add(ColorProperty('color', color));
    description.add(ColorProperty('shadowColor', shadowColor));
  }
}

class _MaterialInteriorState
    extends AnimatedWidgetBaseState<_MaterialInterior> {
  Tween<double>? _elevation;
  ColorTween? _shadowColor;
  ShapeBorderTween? _border;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _elevation = visitor(
      _elevation,
      widget.elevation,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
    _shadowColor = visitor(
      _shadowColor,
      widget.shadowColor,
      (dynamic value) => ColorTween(begin: value as Color),
    ) as ColorTween?;
    _border = visitor(
      _border,
      widget.shape,
      (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder),
    ) as ShapeBorderTween?;
  }

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = _border!.evaluate(animation)!;
    final double elevation = _elevation!.evaluate(animation);
    return PhysicalShape(
      child: _ShapeBorderPaint(
        child: widget.child,
        shape: shape,
        borderOnForeground: widget.borderOnForeground,
      ),
      clipper: ShapeBorderClipper(
        shape: shape,
        textDirection: Directionality.maybeOf(context),
      ),
      clipBehavior: widget.clipBehavior,
      elevation: elevation,
      color: ElevationOverlay.applyOverlay(context, widget.color, elevation),
      shadowColor: _shadowColor!.evaluate(animation)!,
    );
  }
}

class _MaterialState extends State<Material> with TickerProviderStateMixin {
  final GlobalKey<_InkFeaturesContainerState> _inkFeatureRenderer =
      GlobalKey(debugLabel: 'ink renderer');

  Color? _getBackgroundColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Color? color = widget.color;
    if (color == null) {
      switch (widget.type) {
        case MaterialType.canvas:
          color = theme.canvasColor;
          break;
        case MaterialType.card:
          color = theme.cardColor;
          break;
        default:
          break;
      }
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = _getBackgroundColor(context);
    assert(
      backgroundColor != null || widget.type == MaterialType.transparency,
      'If Material type is not MaterialType.transparency, a color must '
      'either be passed in through the `color` property, or be defined '
      'in the theme (ex. canvasColor != null if type is set to '
      'MaterialType.canvas)',
    );
    Widget? contents = widget.child;
    if (contents != null) {
      contents = AnimatedDefaultTextStyle(
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyText2!,
        duration: widget.animationDuration,
        child: contents,
      );
    }
    contents = NotificationListener<LayoutChangedNotification>(
      onNotification: (LayoutChangedNotification notification) {
        _inkFeatureRenderer.currentState!._didChangeLayout();
        return false;
      },
      child: _InkFeaturesContainer(
        key: _inkFeatureRenderer,
        absorbHitTest: widget.type != MaterialType.transparency,
        //color: backgroundColor,
        child: contents,
        vsync: this,
      ),
    );

    // PhysicalModel has a temporary workaround for a performance issue that
    // speeds up rectangular non transparent material (the workaround is to
    // skip the call to ui.Canvas.saveLayer if the border radius is 0).
    // Until the saveLayer performance issue is resolved, we're keeping this
    // special case here for canvas material type that is using the default
    // shape (rectangle). We could go down this fast path for explicitly
    // specified rectangles (e.g shape RoundedRectangleBorder with radius 0, but
    // we choose not to as we want the change from the fast-path to the
    // slow-path to be noticeable in the construction site of Material.
    if (widget.type == MaterialType.canvas &&
        widget.shape == null &&
        widget.borderRadius == null) {
      return AnimatedPhysicalModel(
        curve: Curves.fastOutSlowIn,
        duration: widget.animationDuration,
        shape: BoxShape.rectangle,
        clipBehavior: widget.clipBehavior,
        borderRadius: BorderRadius.zero,
        elevation: widget.elevation,
        color: ElevationOverlay.applyOverlay(
            context, backgroundColor!, widget.elevation),
        shadowColor: widget.shadowColor ?? Theme.of(context).shadowColor,
        animateColor: false,
        child: contents,
      );
    }

    final ShapeBorder shape = _getShape();

    if (widget.type == MaterialType.transparency) {
      return _transparentInterior(
        context: context,
        shape: shape,
        clipBehavior: widget.clipBehavior,
        contents: contents,
      );
    }

    return _MaterialInterior(
      curve: Curves.fastOutSlowIn,
      duration: widget.animationDuration,
      shape: shape,
      borderOnForeground: widget.borderOnForeground,
      clipBehavior: widget.clipBehavior,
      elevation: widget.elevation,
      color: backgroundColor!,
      shadowColor: widget.shadowColor ?? Theme.of(context).shadowColor,
      child: contents,
    );
  }

  static Widget _transparentInterior({
    required BuildContext context,
    required ShapeBorder shape,
    required Clip clipBehavior,
    required Widget contents,
  }) {
    final _ShapeBorderPaint child = _ShapeBorderPaint(
      child: contents,
      shape: shape,
    );
    if (clipBehavior == Clip.none) {
      return child;
    }
    return ClipPath(
      child: child,
      clipper: ShapeBorderClipper(
        shape: shape,
        textDirection: Directionality.maybeOf(context),
      ),
      clipBehavior: clipBehavior,
    );
  }

  // Determines the shape for this Material.
  //
  // If a shape was specified, it will determine the shape.
  // If a borderRadius was specified, the shape is a rounded
  // rectangle.
  // Otherwise, the shape is determined by the widget type as described in the
  // Material class documentation.
  ShapeBorder _getShape() {
    if (widget.shape != null) return widget.shape!;
    if (widget.borderRadius != null)
      return RoundedRectangleBorder(borderRadius: widget.borderRadius!);
    switch (widget.type) {
      case MaterialType.canvas:
      case MaterialType.transparency:
        return const RoundedRectangleBorder();

      case MaterialType.card:
      case MaterialType.button:
        return RoundedRectangleBorder(
          borderRadius: widget.borderRadius ?? kMaterialEdges[widget.type]!,
        );

      case MaterialType.circle:
        return const CircleBorder();
    }
  }
}

class _InkFeaturesContainer extends StatefulWidget {
  final TickerProvider vsync;
  final bool absorbHitTest;
  final Widget? child;

  const _InkFeaturesContainer({
    Key? key,
    required this.vsync,
    required this.absorbHitTest,
    required this.child,
  })  : assert(vsync != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _InkFeaturesContainerState();
}

class _InkFeaturesContainerState extends State<_InkFeaturesContainer>
    implements MaterialInkController {
  _RenderInkFeatures? renderObject;
  // This class should exist in a 1:1 relationship with a MaterialState object,
  // since there's no current support for dynamically changing the ticker
  // provider.
  @override
  TickerProvider get vsync => widget.vsync;

  // This is here to satisfy the MaterialInkController contract.
  // The actual painting of this color is done by a Container in the
  // MaterialState build method.
  @override
  Color? color;

  bool get absorbHitTest => widget.absorbHitTest;

  List<InkFeature>? _inkFeatures;
  bool _needsMarkRepaint = false;
  void markNeedsPaint() => _needsMarkRepaint
      ? setState(() {
          _needsMarkRepaint = false;
        })
      : null;

  void _didChangeLayout() {
    if (_inkFeatures != null && _inkFeatures!.isNotEmpty) markNeedsPaint();
  }

  Widget build(BuildContext context) {
    _needsMarkRepaint = true;
    return ClipRect(
      child: _InkFeatures(
        children: [
          if (widget.child != null) widget.child!,
          ...?_inkFeatures?.map(
              (e) => _InkFeature(feature: e, child: Builder(builder: e.build))),
        ],
        vsync: vsync,
        absorbHitTest: absorbHitTest,
        renderObjectCreated: (o) => renderObject = o,
        hasContentChild: widget.child != null,
      ),
    );
  }

  @override
  void addInkFeature(InkFeature feature) {
    assert(!feature._debugDisposed);
    assert(feature._controller == this);
    _inkFeatures ??= <InkFeature>[];
    assert(!_inkFeatures!.contains(feature));
    _inkFeatures!.add(feature);
    print("Adding ink feature $feature");
    markNeedsPaint();
  }

  void _removeFeature(InkFeature feature) {
    assert(_inkFeatures != null);
    _inkFeatures!.remove(feature);
    markNeedsPaint();
  }
}

class _InkFeature extends SingleChildRenderObjectWidget {
  final InkFeature feature;

  _InkFeature({required this.feature, required Widget child})
      : super(child: child);

  @override
  _RenderInkFeature createRenderObject(BuildContext context) =>
      _RenderInkFeature(feature: feature);

  void updateRenderObject(
    BuildContext context,
    _RenderInkFeature renderObject,
  ) {
    //assert(feature == renderObject.feature);
    renderObject
      ..feature = feature
      ..markNeedsPaint();
  }
}

class _RenderInkFeature extends RenderProxyBox {
  InkFeature feature;

  _RenderInkFeature({required this.feature, RenderBox? child}) : super(child);

  TransformLayer? _transformLayer;
  @override
  void paint(PaintingContext context, Offset offset) {
    final transform = feature._paintTransformFromInkController();
    if (feature._renderCanvas) {
      final Canvas canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.clipRect(Offset.zero & size);
      feature.paintFeature(canvas, transform);
      canvas.restore();
    }

    if (feature._renderWidget) {
      _transformLayer ??= TransformLayer();
      _transformLayer!..transform = transform;
      context.pushLayer(_transformLayer!, (context, offset) {
        context.pushClipRect(
          needsCompositing,
          offset,
          Offset.zero & feature.referenceBox.size,
          super.paint,
        );
      }, offset);
    }
  }
}

class _RenderInkFeatures extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StackParentData> {
  _RenderInkFeatures({
    this.color,
    required this.vsync,
    required this.absorbHitTest,
    required this.hasContentChild,
  });

  // This widget must be owned by a MaterialState, which must be provided as the vsync.
  // This relationship must be 1:1 and cannot change for the lifetime of the MaterialState.

  Color? color;
  bool hasContentChild;

  final TickerProvider vsync;

  bool absorbHitTest;
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasContentChild) {
      return false;
    }
    return firstChild!.hitTest(result, position: position);
  }

  bool _hasVisualOverflow = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StackParentData)
      child.parentData = StackParentData();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  /// Lays out the positioned `child` according to `alignment` within a Stack of `size`.
  ///
  /// Returns true when the child has visual overflow.
  static bool layoutPositionedChild(RenderBox child,
      StackParentData childParentData, Size size, Alignment alignment) {
    assert(childParentData.isPositioned);
    assert(child.parentData == childParentData);

    bool hasVisualOverflow = false;
    BoxConstraints childConstraints = const BoxConstraints();

    if (childParentData.left != null && childParentData.right != null)
      childConstraints = childConstraints.tighten(
          width: size.width - childParentData.right! - childParentData.left!);
    else if (childParentData.width != null)
      childConstraints = childConstraints.tighten(width: childParentData.width);

    if (childParentData.top != null && childParentData.bottom != null)
      childConstraints = childConstraints.tighten(
          height: size.height - childParentData.bottom! - childParentData.top!);
    else if (childParentData.height != null)
      childConstraints =
          childConstraints.tighten(height: childParentData.height);

    child.layout(childConstraints, parentUsesSize: true);

    late final double x;
    if (childParentData.left != null) {
      x = childParentData.left!;
    } else if (childParentData.right != null) {
      x = size.width - childParentData.right! - child.size.width;
    } else {
      x = alignment.alongOffset(size - child.size as Offset).dx;
    }

    if (x < 0.0 || x + child.size.width > size.width) hasVisualOverflow = true;

    late final double y;
    if (childParentData.top != null) {
      y = childParentData.top!;
    } else if (childParentData.bottom != null) {
      y = size.height - childParentData.bottom! - child.size.height;
    } else {
      y = alignment.alongOffset(size - child.size as Offset).dy;
    }

    if (y < 0.0 || y + child.size.height > size.height)
      hasVisualOverflow = true;

    childParentData.offset = Offset(x, y);

    return hasVisualOverflow;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
      hasContentChild: hasContentChild,
    );
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
    required bool hasContentChild,
  }) {
    bool hasNonPositionedChildren = false;
    if (childCount == 0) {
      assert(constraints.biggest.isFinite);
      return constraints.biggest;
    }

    double width = constraints.minWidth;
    double height = constraints.minHeight;

    final BoxConstraints nonPositionedConstraints;
    switch (StackFit.passthrough) {
      case StackFit.loose:
        nonPositionedConstraints = constraints.loosen();
        break;
      case StackFit.expand:
        nonPositionedConstraints = BoxConstraints.tight(constraints.biggest);
        break;
      case StackFit.passthrough:
        nonPositionedConstraints = constraints;
        break;
    }
    assert(nonPositionedConstraints != null);

    // the size of the first widget, which should be the actual content
    Size? materialSize;

    RenderBox? child = firstChild;
    while (child != null) {
      final StackParentData childParentData =
          child.parentData! as StackParentData;

      if (!childParentData.isPositioned) {
        hasNonPositionedChildren = true;
        final constraints;
        if (materialSize != null) {
          constraints = BoxConstraints.tight(materialSize);
        } else {
          constraints = nonPositionedConstraints;
        }
        final Size childSize = layoutChild(child, constraints);

        width = math.max(width, childSize.width);
        height = math.max(height, childSize.height);
      }

      child = childParentData.nextSibling;
      materialSize ??= Size(width, height);
    }

    final Size size;
    if (hasContentChild) {
      size = materialSize!;
    } else if (hasNonPositionedChildren) {
      size = Size(width, height);
      assert(size.width == constraints.constrainWidth(width));
      assert(size.height == constraints.constrainHeight(height));
    } else {
      size = constraints.biggest;
    }

    assert(size.isFinite);
    return size;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    _hasVisualOverflow = false;

    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
      hasContentChild: hasContentChild,
    );
    final alignment = Alignment.center;
    RenderBox? child = firstChild;
    while (child != null) {
      final StackParentData childParentData =
          child.parentData! as StackParentData;

      if (!childParentData.isPositioned) {
        childParentData.offset =
            alignment.alongOffset(size - child.size as Offset);
      } else {
        _hasVisualOverflow =
            layoutPositionedChild(child, childParentData, size, alignment) ||
                _hasVisualOverflow;
      }

      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  /// Override in subclasses to customize how the stack paints.
  ///
  /// By default, the stack uses [defaultPaint]. This function is called by
  /// [paint] after potentially applying a clip to contain visual overflow.
  @protected
  void paintStack(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _clipRectLayer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      paintStack,
      clipBehavior: Clip.hardEdge,
      oldLayer: _clipRectLayer,
    );
  }

  ClipRectLayer? _clipRectLayer;

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _hasVisualOverflow ? Offset.zero & size : null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _InkFeatures extends MultiChildRenderObjectWidget {
  _InkFeatures({
    Key? key,
    this.color,
    required this.vsync,
    required this.absorbHitTest,
    required this.renderObjectCreated,
    required this.hasContentChild,
    required List<Widget> children,
  }) : super(
          key: key,
          children: children,
        );

  // This widget must be owned by a MaterialState, which must be provided as the vsync.
  // This relationship must be 1:1 and cannot change for the lifetime of the MaterialState.

  final Color? color;

  final TickerProvider vsync;

  final bool absorbHitTest;
  final ValueChanged<_RenderInkFeatures> renderObjectCreated;
  final bool hasContentChild;

  @override
  _RenderInkFeatures createRenderObject(BuildContext context) {
    final renderObject = _RenderInkFeatures(
      color: color,
      absorbHitTest: absorbHitTest,
      hasContentChild: hasContentChild,
      vsync: vsync,
    );
    renderObjectCreated(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInkFeatures renderObject) {
    renderObject
      ..color = color
      ..absorbHitTest = absorbHitTest
      ..hasContentChild = hasContentChild;
    assert(vsync == renderObject.vsync);
  }
}

/// A visual reaction on a piece of [Material].
///
/// To add an ink feature to a piece of [Material], obtain the
/// [MaterialInkController] via [Material.of] and call
/// [MaterialInkController.addInkFeature].
abstract class InkFeature {
  /// Initializes fields for subclasses.
  InkFeature({
    required MaterialInkController controller,
    required this.referenceBox,
    this.onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        _controller = controller as _InkFeaturesContainerState;

  /// The [MaterialInkController] associated with this [InkFeature].
  ///
  /// Typically used by subclasses to call
  /// [MaterialInkController.markNeedsPaint] when they need to repaint.
  MaterialInkController get controller => _controller;
  final _InkFeaturesContainerState _controller;

  /// The render box whose visual position defines the frame of reference for this ink feature.
  final RenderBox referenceBox;

  /// Called when the ink feature is no longer visible on the material.
  final VoidCallback? onRemoved;

  bool _debugDisposed = false;

  /// Free up the resources associated with this ink feature.
  @mustCallSuper
  void dispose() {
    assert(!_debugDisposed);
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    _controller._removeFeature(this);
    onRemoved?.call();
  }

  /// Whether or not we should setup the [Canvas] for actually
  /// rendering with the [paintFeature] method.
  bool _renderCanvas = true;

  /// Override this method to paint the ink feature.
  ///
  /// The transform argument gives the coordinate conversion from the coordinate
  /// system of the canvas to the coordinate system of the [referenceBox].
  @protected
  void paintFeature(Canvas canvas, Matrix4 transform) {
    _renderCanvas = false;
  }

  Matrix4 _paintTransformFromInkController() {
    assert(referenceBox.attached);
    assert(!_debugDisposed);
    // find the chain of renderers from us to the feature's referenceBox
    final List<RenderObject> descendants = <RenderObject>[referenceBox];
    RenderObject node = referenceBox;
    while (node != _controller.renderObject) {
      node = node.parent! as RenderObject;
      descendants.add(node);
    }
    // determine the transform that gets our coordinate system to be like theirs
    final Matrix4 transform = Matrix4.identity();
    assert(descendants.length >= 2);
    for (int index = descendants.length - 1; index > 0; index -= 1)
      descendants[index].applyPaintTransform(descendants[index - 1], transform);
    return transform;
  }

  /// Whether or not we should setup the [PaintingContext] for actually
  /// rendering an child widget.
  bool _renderWidget = true;

  /// The widget that will be rendered. Override this method if you wish to use
  /// [Widget] to build your [InkFeature]. Prefer using [paintFeature], as it
  /// is cheaper.
  Widget build(BuildContext context) {
    _renderWidget = false;
    return SizedBox.expand();
  }

  @override
  String toString() => describeIdentity(this);
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
  });

  final Widget child;
  final ShapeBorder shape;
  final bool borderOnForeground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: child,
      painter: borderOnForeground
          ? null
          : _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
      foregroundPainter: borderOnForeground
          ? _ShapeBorderPainter(shape, Directionality.maybeOf(context))
          : null,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}
