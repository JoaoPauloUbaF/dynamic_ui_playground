/// A generic node that represents a widget in a dynamic UI tree.
///
/// Example JSON shape:
/// {
///   "type": "container",
///   "props": {"color": "#FF0000", "padding": {"all": 16}},
///   "children": [
///     {"type": "text", "props": {"value": "Hello"}}
///   ]
/// }
class WidgetNode {
  WidgetNode({required this.type, this.props, List<WidgetNode>? children})
    : children = children ?? const [];

  final String type;
  final Map<String, dynamic>? props;
  final List<WidgetNode> children;

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    return WidgetNode(
      type: (json['type'] as String?)?.toLowerCase() ?? 'unknown',
      props: (json['props'] as Map?)?.cast<String, dynamic>(),
      children: ((json['children'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => WidgetNode.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (props != null) 'props': props,
    if (children.isNotEmpty)
      'children': children.map((e) => e.toJson()).toList(),
  };
}
