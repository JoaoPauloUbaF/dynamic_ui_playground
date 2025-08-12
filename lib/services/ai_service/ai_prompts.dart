import 'dart:convert';

class AiPrompts {
  /// Builds a system-style prompt for initial UI creation.
  static String initialUiPrompt({required String prompt}) {
    return '''
You are a UI generator that returns Flutter-compatible JSON describing a widget tree.
Rules:
- Return ONLY valid JSON (no markdown fences, no comments).
- JSON shape: {"type": string, "props": object (optional), "children": array of Nodes (optional)}
- Use these supported types: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.
- Prefer wrapping long vertical content in {"type":"scroll"}.
- For rows that might overflow, wrap each child with {"type":"flexible","props":{"flex":1}}.
- Use hex ARGB colors like "#FFFFFFFF" when specifying colors.
- Keep values minimal and sane (e.g., text sizes 12-24 for typical text).

User prompt:
$prompt

Return only the JSON object of the UI.
''';
  }

  /// Builds an update instruction prompt for transforming an existing UI JSON.
  static String updateUiPrompt({
    required String instruction,
    required Map<String, dynamic> currentJson,
  }) {
    final current = _minify(currentJson);
    return '''
You are a UI editor that updates an existing Flutter-compatible UI JSON.
Rules:
- Return ONLY valid JSON (no markdown fences, no comments).
- Preserve unspecified properties and structure where possible.
- JSON shape remains: {"type": string, "props": object?, "children": Node[]?}.
- Prefer wrapping long vertical content in {"type":"scroll"}.
- For rows that might overflow, ensure each child is wrapped in a flexible with flex:1 when appropriate.
- If you add padding, use a single-child wrapper: {"type":"padding","props":{"padding":{"all":N}}}.
- Use available DS types: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.

Instruction:
$instruction

Current JSON:
$current

Return only the updated JSON object.
''';
  }

  /// Prompt for audio-based updates: the audio contains the user's spoken instruction.
  static String audioUpdateUiPrompt({
    required String guidance,
    required Map<String, dynamic> currentJson,
  }) {
    final current = _minify(currentJson);
    return '''
You are a UI editor that updates an existing Flutter-compatible UI JSON.
You will receive an audio clip containing the user's instruction. If the audio contains background filler words, ignore them and extract the intended change.
Rules:
- Return ONLY valid JSON (no markdown fences, no comments).
- Preserve unspecified properties and structure where possible.
- JSON shape remains: {"type": string, "props": object?, "children": Node[]?}.
- Prefer wrapping long vertical content in {"type":"scroll"}.
- For rows that might overflow, ensure each child is wrapped in a flexible with flex:1 when appropriate.
- If you add padding, use a single-child wrapper: {"type":"padding","props":{"padding":{"all":N}}}.
- Use available DS types: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.

Context (text guidance):
$guidance

Current JSON:
$current

Return only the updated JSON object.
''';
  }

  static String _minify(Map<String, dynamic> json) =>
      const JsonEncoder().convert(json);
}
