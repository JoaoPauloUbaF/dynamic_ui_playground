import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../../utils/common_props.dart';

class ContainerDS extends BaseDS<Container> {
  ContainerDS({this.decoration, this.alignment, this.padding, this.child, this.themeVariant});

  final BoxDecoration? decoration;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final Widget? child;
  final String? themeVariant;

  @override
  String get type => 'container';

  @override
  Container build() {
    Widget? c = child;
    if (padding != null && c != null) c = Padding(padding: padding!, child: c);
    if (alignment != null && c != null) {
      c = Align(alignment: alignment!, child: c);
    }

    // If a themeVariant is provided, resolve the color from Theme at build time.
    if (themeVariant != null) {
      return Builder(
        builder: (ctx) {
          final scheme = Theme.of(ctx).colorScheme;
          Color? themedColor;
          switch (themeVariant) {
            case 'primaryContainer':
              themedColor = scheme.primaryContainer;
              break;
            case 'secondaryContainer':
              themedColor = scheme.secondaryContainer;
              break;
            case 'tertiaryContainer':
              themedColor = scheme.tertiaryContainer;
              break;
            case 'surfaceContainer':
              // Fallback to surface if not available in current SDK
              themedColor = (scheme as dynamic).surfaceContainer ?? scheme.surface;
              break;
            case 'surface':
              themedColor = scheme.surface;
              break;
            case 'background':
              themedColor = scheme.background;
              break;
            case 'inversePrimary':
              themedColor = scheme.inversePrimary;
              break;
            default:
              themedColor = null;
          }
          final radius = decoration?.borderRadius;
          final border = decoration?.border;
          final deco = BoxDecoration(color: themedColor, borderRadius: radius, border: border);
          return Container(decoration: deco, child: c);
        },
      );
    }

    return Container(decoration: decoration, child: c);
  }

  factory ContainerDS.fromJson(Map<String, dynamic> json, Widget? child) {
    // Backward compatibility: if only 'color' exists, wrap into a BoxDecoration
    final decoMap = json['decoration'];
    final BoxDecoration? deco =
        _boxDecorationFromJson(decoMap) ??
        (json['color'] != null
            ? BoxDecoration(color: CommonProps.parseColor(json['color']))
            : null);

    final String? variant = (decoMap is Map) ? (decoMap['variant'] as String?) : null;

    return ContainerDS(
      decoration: deco,
      alignment: CommonProps.parseAlignment(json['alignment']),
      padding: CommonProps.parsePadding(json['padding']),
      child: child,
      themeVariant: variant,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (decoration != null) 'decoration': _boxDecorationToJson(decoration!),
    if (alignment != null)
      'alignment': CommonProps.alignmentToString(alignment),
    if (padding != null) 'padding': CommonProps.paddingToJson(padding),
  };
}

BoxDecoration? _boxDecorationFromJson(dynamic value) {
  if (value is! Map) return null;
  final map = value;
  final color = CommonProps.parseColor(map['color']);
  final radius = _borderRadiusFromJson(map['borderRadius']);
  final border = _borderFromJson(map['border']);
  return BoxDecoration(color: color, borderRadius: radius, border: border);
}

Map<String, dynamic>? _boxDecorationToJson(BoxDecoration? deco) {
  if (deco == null) return null;
  return {
    if (deco.color != null) 'color': CommonProps.colorToHex(deco.color),
    if (deco.border != null) 'border': _borderToJson(deco.border!),
  };
}

BorderRadius? _borderRadiusFromJson(dynamic value) {
  if (value is Map) {
    if (value['all'] != null) {
      final d = (value['all'] as num).toDouble();
      return BorderRadius.circular(d);
    }
  }
  if (value is num) return BorderRadius.circular(value.toDouble());
  return null;
}

Border? _borderFromJson(dynamic value) {
  if (value is! Map) return null;
  final color = CommonProps.parseColor(value['color']);
  final width = (value['width'] as num?)?.toDouble() ?? 1.0;
  if (color == null) return null;
  return Border.all(color: color, width: width);
}

Map<String, dynamic>? _borderToJson(BoxBorder border) {
  if (border is Border) {
    // Assume uniform border for simplicity
    final side = border.top;
    return {'color': CommonProps.colorToHex(side.color), 'width': side.width};
  }
  return null;
}
