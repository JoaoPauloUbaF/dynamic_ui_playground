import 'package:flutter/material.dart';
import '../model/widget_node_model.dart';
import '../utils/common_props.dart';

/// Extensions and helpers for mapping WidgetNode to concrete Widgets.
/// Keep this basic and safe; extend as needed.
extension WidgetNodeToWidget on WidgetNode {
  Widget toWidget() {
    switch (type) {
      case 'text':
        final value = props?['value']?.toString() ?? '';
        final color = CommonProps.parseColor(props?['color']);
        final size = (props?['size'] as num?)?.toDouble();
        return Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: size,
          ),
          textAlign: _parseTextAlign(props?['align']) ?? TextAlign.start,
        );
      case 'container':
        final color = CommonProps.parseColor(props?['color']);
        final padding = CommonProps.parsePadding(props?['padding']);
        final align = CommonProps.parseAlignment(props?['alignment']);
        final child = children.isNotEmpty ? children.first.toWidget() : null;
        Widget c = child ?? const SizedBox.shrink();
        if (padding != null) c = Padding(padding: padding, child: c);
        if (align != null) c = Align(alignment: align, child: c);
        return Container(color: color, child: c);
      case 'column':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children.map((e) => e.toWidget()).toList(),
        );
      case 'row':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: children.map((e) => e.toWidget()).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

TextAlign? _parseTextAlign(dynamic value) {
  switch (value) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'left':
      return TextAlign.left;
    default:
      return null;
  }
}

