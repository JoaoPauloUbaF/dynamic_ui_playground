import 'package:flutter/material.dart';
import '../base_ds.dart';

class TextFieldDS extends BaseDS<TextField> {
  TextFieldDS({this.hint, this.obscureText});
  final String? hint;
  final bool? obscureText;

  @override
  String get type => 'textField';

  @override
  TextField build() => TextField(
        decoration: InputDecoration(hintText: hint),
        obscureText: obscureText ?? false,
      );

  factory TextFieldDS.fromJson(Map<String, dynamic> json) => TextFieldDS(
        hint: json['hint']?.toString(),
        obscureText: json['obscureText'] as bool?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (hint != null) 'hint': hint,
        if (obscureText != null) 'obscureText': obscureText,
      };
}

