import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../base_ds.dart';
import '../../../features/dynamic_ui/utils/common_props.dart';

class IconDS extends BaseDS<Widget> {
  IconDS({
    required this.iconName,
    this.color,
    this.size,
    this.material3 = false,
    this.m3Style = 'outlined', // outlined | rounded | sharp
    this.m3Fill,
    this.m3Weight,
    this.m3Grade,
    this.m3OpticalSize,
  }) : icon = _iconFromName(iconName);

  final String iconName;
  final IconData icon;
  final Color? color;
  final double? size;

  // Material 3 ligature-based rendering
  final bool material3;
  final String m3Style;
  final int? m3Fill; // 0 or 1
  final int? m3Weight; // e.g., 400
  final int? m3Grade; // e.g., 0
  final int? m3OpticalSize; // e.g., 48

  @override
  String get type => 'icon';

  @override
  Widget build() {
    if (material3) {
      final family = _m3Family(m3Style);
      final ts = GoogleFonts.getFont(
        family,
        textStyle: TextStyle(
          color: color,
          fontSize: size,
          fontVariations: [
            if (m3Fill != null) FontVariation('FILL', m3Fill!.toDouble()),
            if (m3Weight != null) FontVariation('wght', m3Weight!.toDouble()),
            if (m3Grade != null) FontVariation('GRAD', m3Grade!.toDouble()),
            if (m3OpticalSize != null) FontVariation('opsz', m3OpticalSize!.toDouble()),
          ],
        ),
      );
      return Text(iconName, style: ts);
    }
    return Icon(icon, color: color, size: size);
  }

  factory IconDS.fromJson(Map<String, dynamic> json) => IconDS(
        iconName: (json['icon'] ?? 'mic').toString(),
        color: CommonProps.parseColor(json['color']),
        size: (json['size'] as num?)?.toDouble(),
        material3: json['material3'] == true,
        m3Style: (json['m3Style'] ?? 'outlined').toString(),
        m3Fill: json['m3Fill'] as int?,
        m3Weight: json['m3Weight'] as int?,
        m3Grade: json['m3Grade'] as int?,
        m3OpticalSize: json['m3OpticalSize'] as int?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'icon': iconName,
        if (color != null) 'color': CommonProps.colorToHex(color),
        if (size != null) 'size': size,
        if (material3) 'material3': true,
        if (material3) 'm3Style': m3Style,
        if (m3Fill != null) 'm3Fill': m3Fill,
        if (m3Weight != null) 'm3Weight': m3Weight,
        if (m3Grade != null) 'm3Grade': m3Grade,
        if (m3OpticalSize != null) 'm3OpticalSize': m3OpticalSize,
      };
}

String _m3Family(String style) {
  switch (style) {
    case 'rounded':
      return 'Material Symbols Rounded';
    case 'sharp':
      return 'Material Symbols Sharp';
    case 'outlined':
    default:
      return 'Material Symbols Outlined';
  }
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
