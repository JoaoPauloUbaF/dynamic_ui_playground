import 'package:flutter/material.dart';
import 'package:dynamic_ui_playground/core/design_system/base_ds.dart';
import 'package:dynamic_ui_playground/core/design_system/ds_helpers.dart';

class ColumnDS extends BaseDS<Column> {
  ColumnDS({this.mainAxisAlignment, this.crossAxisAlignment, this.children = const []});

  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<Widget> children;

  @override
  String get type => 'column';

  @override
  Column build() => Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children,
      );

  factory ColumnDS.fromJson(Map<String, dynamic> json, List<Widget> children) => ColumnDS(
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

