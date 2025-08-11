import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../../../features/dynamic_ui/utils/common_props.dart';
import '../ds_helpers.dart';

import 'package:google_fonts/google_fonts.dart';
class TextDS extends BaseDS<Text> {
  TextDS({required this.value, this.color, this.size, this.align, this.fontFamily, this.overflow, this.maxLines});
  final String value;
  final Color? color;
  final double? size;
  final TextAlign? align;
  final String? fontFamily; // Google Fonts
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  String get type => 'text';

  @override
  Text build() {
    TextStyle base = TextStyle(color: color, fontSize: size, overflow: overflow);
    if (fontFamily != null && fontFamily!.isNotEmpty) {
      base = GoogleFonts.getFont(fontFamily!, textStyle: base);
    }
    return Text(
      value,
      textAlign: align,
      style: base,
      maxLines: maxLines,
    );
  }

  factory TextDS.fromJson(Map<String, dynamic> json) => TextDS(
        value: (json['value'] ?? '').toString(),
        color: CommonProps.parseColor(json['color']),
        size: (json['size'] as num?)?.toDouble(),
        align: stringToTextAlign(json['align']),
        fontFamily: json['fontFamily'] as String?,
        overflow: _stringToOverflow(json['overflow']),
        maxLines: json['maxLines'] as int?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        if (color != null) 'color': CommonProps.colorToHex(color),
        if (size != null) 'size': size,
        if (align != null) 'align': textAlignToString(align!),
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (overflow != null) 'overflow': _overflowToString(overflow!),
        if (maxLines != null) 'maxLines': maxLines,
      };
}

TextOverflow? _stringToOverflow(dynamic s) {
  switch (s) {
    case 'ellipsis':
      return TextOverflow.ellipsis;
    case 'fade':
      return TextOverflow.fade;
    case 'clip':
      return TextOverflow.clip;
    case 'visible':
      return TextOverflow.visible;
    default:
      return null;
  }
}

String _overflowToString(TextOverflow v) {
  switch (v) {
    case TextOverflow.ellipsis:
      return 'ellipsis';
    case TextOverflow.fade:
      return 'fade';
    case TextOverflow.clip:
      return 'clip';
    case TextOverflow.visible:
    default:
      return 'visible';
  }
}
