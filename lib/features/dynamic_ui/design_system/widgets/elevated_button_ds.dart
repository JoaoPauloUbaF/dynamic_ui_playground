import 'package:flutter/material.dart';
import '../base_ds.dart';

class ElevatedButtonDS extends BaseDS<ElevatedButton> {
  ElevatedButtonDS({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  String get type => 'elevatedButton';

  @override
  ElevatedButton build() => ElevatedButton(onPressed: onPressed, child: Text(label));

  factory ElevatedButtonDS.fromJson(Map<String, dynamic> json) =>
      ElevatedButtonDS(label: (json['label'] ?? '').toString());

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
      };
}

