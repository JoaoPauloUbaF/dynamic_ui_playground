import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../../utils/common_props.dart';

class ContainerDS extends BaseDS<Container> {
  ContainerDS({this.color, this.alignment, this.padding, this.child});

  final Color? color;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  String get type => 'container';

  @override
  Container build() {
    Widget? c = child;
    if (padding != null && c != null) c = Padding(padding: padding!, child: c);
    if (alignment != null && c != null) c = Align(alignment: alignment!, child: c);
    return Container(color: color, child: c);
  }

  factory ContainerDS.fromJson(Map<String, dynamic> json, Widget? child) {
    return ContainerDS(
      color: CommonProps.parseColor(json['color']),
      alignment: CommonProps.parseAlignment(json['alignment']),
      padding: CommonProps.parsePadding(json['padding']),
      child: child,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (color != null) 'color': CommonProps.colorToHex(color),
        if (alignment != null) 'alignment': CommonProps.alignmentToString(alignment),
        if (padding != null) 'padding': CommonProps.paddingToJson(padding),
      };
}

