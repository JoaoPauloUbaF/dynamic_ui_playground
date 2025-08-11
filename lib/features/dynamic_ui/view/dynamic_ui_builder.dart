import 'package:flutter/material.dart';
import '../../dynamic_ui/design_system/widgets_ds.dart';

/// Builds a widget tree recursively from a JSON node using DS widgets.
class DynamicUiBuilder extends StatelessWidget {
  const DynamicUiBuilder({super.key, required this.json});

  final Map<String, dynamic> json;

  @override
  Widget build(BuildContext context) {
    return _buildFromJson(json);
  }
}

Widget _buildFromJson(Map<String, dynamic> node) {
  final type = (node['type'] as String?)?.toLowerCase() ?? 'unknown';
  final props = (node['props'] as Map?)?.cast<String, dynamic>() ?? const {};
  final childrenJson = (node['children'] as List?)?.cast<dynamic>() ?? const [];

  List<Widget> childrenWidgets = childrenJson
      .whereType<Map>()
      .map((c) => _buildFromJson(c.cast<String, dynamic>()))
      .toList();

  switch (type) {
    case 'row':
      return RowDS.fromJson(props, childrenWidgets).build();
    case 'column':
      return ColumnDS.fromJson(props, childrenWidgets).build();
    case 'container':
      final Widget? child = childrenWidgets.isNotEmpty ? childrenWidgets.first : null;
      return ContainerDS.fromJson(props, child).build();
    case 'sizedbox':
    case 'sized_box':
      final Widget? child = childrenWidgets.isNotEmpty ? childrenWidgets.first : null;
      return SizedBoxDS.fromJson(props, child).build();
    case 'text':
      return TextDS.fromJson(props).build();
    case 'icon':
      return IconDS.fromJson(props).build();
    case 'image':
      return ImageDS.fromJson(props).build();
    case 'elevatedbutton':
    case 'elevated_button':
      return ElevatedButtonDS.fromJson(props).build();
    case 'textfield':
    case 'text_field':
      return TextFieldDS.fromJson(props).build();
    default:
      return const SizedBox.shrink();
  }
}

