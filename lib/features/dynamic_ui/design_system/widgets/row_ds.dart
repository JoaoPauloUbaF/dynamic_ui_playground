import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../ds_helpers.dart';

class RowDS extends BaseDS<Row> {
  RowDS({this.mainAxisAlignment, this.crossAxisAlignment, this.children = const []});

  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<Widget> children;

  @override
  String get type => 'row';

  @override
  Row build() => Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children,
      );

  factory RowDS.fromJson(Map<String, dynamic> json, List<Widget> children) => RowDS(
        mainAxisAlignment: stringToMainAxis(json['mainAxisAlignment']),
        crossAxisAlignment: stringToCrossAxis(json['crossAxisAlignment']),
        children: children,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (mainAxisAlignment != null) 'mainAxisAlignment': mainAxisToString(mainAxisAlignment!),
        if (crossAxisAlignment != null) 'crossAxisAlignment': crossAxisToString(crossAxisAlignment!),
      };
}

