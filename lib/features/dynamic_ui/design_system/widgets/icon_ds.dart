import 'package:flutter/material.dart';
import 'package:dynamic_ui_playground/core/design_system/base_ds.dart';
import 'package:dynamic_ui_playground/features/dynamic_ui/utils/common_props.dart';

class IconDS extends BaseDS<Icon> {
  IconDS({required this.iconName, this.color, this.size}) : icon = _iconFromName(iconName);
  final String iconName;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  String get type => 'icon';

  @override
  Icon build() => Icon(icon, color: color, size: size);

  factory IconDS.fromJson(Map<String, dynamic> json) => IconDS(
        iconName: (json['icon'] ?? 'mic').toString(),
        color: CommonProps.parseColor(json['color']),
        size: (json['size'] as num?)?.toDouble(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'icon': iconName,
        if (color != null) 'color': CommonProps.colorToHex(color),
        if (size != null) 'size': size,
      };
}

IconData _iconFromName(String name) {
  switch (name) {
    case 'mic':
      return Icons.mic;
    case 'add':
      return Icons.add;
    case 'close':
      return Icons.close;
    default:
      return Icons.circle;
  }
}

