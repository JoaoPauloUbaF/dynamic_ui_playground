import 'package:flutter/material.dart';
import 'package:dynamic_ui_playground/core/design_system/base_ds.dart';
import 'package:dynamic_ui_playground/features/dynamic_ui/utils/common_props.dart';
import 'package:dynamic_ui_playground/core/design_system/ds_helpers.dart';

class TextDS extends BaseDS<Text> {
  TextDS({required this.value, this.color, this.size, this.align});
  final String value;
  final Color? color;
  final double? size;
  final TextAlign? align;

  @override
  String get type => 'text';

  @override
  Text build() => Text(
        value,
        textAlign: align,
        style: TextStyle(color: color, fontSize: size),
      );

  factory TextDS.fromJson(Map<String, dynamic> json) => TextDS(
        value: (json['value'] ?? '').toString(),
        color: CommonProps.parseColor(json['color']),
        size: (json['size'] as num?)?.toDouble(),
        align: stringToTextAlign(json['align']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        if (color != null) 'color': CommonProps.colorToHex(color),
        if (size != null) 'size': size,
        if (align != null) 'align': textAlignToString(align!),
      };
}

