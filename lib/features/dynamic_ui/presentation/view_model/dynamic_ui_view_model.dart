import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_ui_playground/services/ai_service/ai_service_provider.dart';
import 'package:dynamic_ui_playground/services/ai_service/ai_service.dart';
import '../../domain/providers/ui_json_provider.dart';

/// Singleton ViewModel that bridges UI (WidgetRef) and the async JSON provider.
class DynamicUiViewModel {
  DynamicUiViewModel._internal();
  static final DynamicUiViewModel instance = DynamicUiViewModel._internal();

  WidgetRef? _ref;
  Map<String, dynamic>? _lastValid;

  // History stacks for undo/redo
  final List<Map<String, dynamic>> _past = [];
  final List<Map<String, dynamic>> _future = [];
  int _maxHistory = 50;

  void attach(WidgetRef ref) {
    _ref = ref;
  }

  // Expose ability to configure history cap
  set maxHistory(int value) {
    if (value <= 0) return;
    _maxHistory = value;
    while (_past.length > _maxHistory) {
      _past.removeAt(0);
    }
  }

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  /// Watch the async JSON value. Call from a ConsumerWidget/ConsumerState.
  AsyncValue<Map<String, dynamic>> watchJson() {
    final ref = _ref;
    if (ref == null) {
      return const AsyncValue.data(kDefaultDynamicUiJson);
    }

    final value = ref.watch(dynamicUiJsonProvider);
    // Update last valid if data
    value.whenData((data) => _lastValid = data);
    return value;
  }

  /// Returns last valid JSON or the default one if none yet.
  Map<String, dynamic> get lastValidOrDefault =>
      _lastValid ?? kDefaultDynamicUiJson;

  Map<String, dynamic> _deepCopy(Map<String, dynamic> m) =>
      json.decode(json.encode(m)) as Map<String, dynamic>;

  bool _deepEquals(Map<String, dynamic> a, Map<String, dynamic> b) =>
      json.encode(a) == json.encode(b);

  /// Apply a new JSON to the provider while recording history and clearing redo.
  void applyNewJson(Map<String, dynamic> newJson, {WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef; // keep latest valid ref
    final current =
        useRef.read(dynamicUiJsonProvider).value ?? lastValidOrDefault;
    if (_deepEquals(current, newJson)) {
      // No change, don't spam history
      return;
    }
    _past.add(_deepCopy(current));
    while (_past.length > _maxHistory) {
      _past.removeAt(0);
    }
    _future.clear();
    _lastValid = _deepCopy(newJson);
    useRef.read(dynamicUiJsonProvider.notifier).applyJson(newJson);
  }

  void undo({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    if (_past.isEmpty) return;
    final current =
        useRef.read(dynamicUiJsonProvider).value ?? lastValidOrDefault;
    _future.add(_deepCopy(current));
    final prev = _past.removeLast();
    _lastValid = _deepCopy(prev);
    useRef.read(dynamicUiJsonProvider.notifier).applyJson(prev);
  }

  void redo({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    if (_future.isEmpty) return;
    final current =
        useRef.read(dynamicUiJsonProvider).value ?? lastValidOrDefault;
    _past.add(_deepCopy(current));
    final next = _future.removeLast();
    _lastValid = _deepCopy(next);
    useRef.read(dynamicUiJsonProvider.notifier).applyJson(next);
  }

  /// Trigger a refresh (simulated fetch).
  Future<void> refresh({WidgetRef? ref}) async {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    await useRef.read(dynamicUiJsonProvider.notifier).refreshFromServer();
  }

  /// Reset back to default JSON.
  void resetToDefault({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    useRef.read(dynamicUiJsonProvider.notifier).resetToDefault();
  }

  AiService? get _ai => _ref?.read(aiServiceProvider);

  // CREATE flows
  Future<void> applyCreateText(String prompt) async {
    final ref = _ref;
    final ai = _ai;
    if (ref == null || ai == null) return;
    ref.read(dynamicUiJsonProvider.notifier).setLoading();
    try {
      final created = await ai.createUiFromText(prompt: prompt);
      applyNewJson(created);
    } catch (e) {
      // fallback to last valid and rethrow for UI handling (no history change)
      ref.read(dynamicUiJsonProvider.notifier).applyJson(lastValidOrDefault);
      rethrow;
    }
  }

  Future<void> applyCreateAudio(String prompt) async {
    final ref = _ref;
    final ai = _ai;
    if (ref == null || ai == null) return;
    ref.read(dynamicUiJsonProvider.notifier).setLoading();
    try {
      final created = await ai.createUiFromAudio(prompt: prompt);
      applyNewJson(created);
    } catch (e) {
      // no history change on error
      ref.read(dynamicUiJsonProvider.notifier).applyJson(lastValidOrDefault);
      rethrow;
    }
  }

  // UPDATE flows
  /// Apply a text prompt via the AI service and update the provider.
  Future<void> applyTextPrompt(String prompt) async {
    final ref = _ref;
    final ai = _ai;
    if (ref == null || ai == null) return;
    // set loading
    ref.read(dynamicUiJsonProvider.notifier).setLoading();
    final current = lastValidOrDefault;
    try {
      final updated = await ai.updateUiFromText(
        prompt: prompt,
        currentJson: current,
      );
      applyNewJson(updated);
    } catch (e) {
      // on error, restore last valid and bubble up
      ref.read(dynamicUiJsonProvider.notifier).applyJson(current);
      rethrow;
    }
  }

  /// Capture audio (handled by service) + prompt and update UI JSON.
  Future<void> applyAudioPrompt(String prompt) async {
    final ref = _ref;
    final ai = _ai;
    if (ref == null || ai == null) return;
    ref.read(dynamicUiJsonProvider.notifier).setLoading();
    final current = lastValidOrDefault;
    try {
      final updated = await ai.updateUiFromAudio(
        prompt: prompt,
        currentJson: current,
      );
      applyNewJson(updated);
    } catch (e) {
      ref.read(dynamicUiJsonProvider.notifier).applyJson(current);
      rethrow;
    }
  }
}

// Kept for backward-compatibility in case anything references default JSON here.
Map<String, dynamic> get legacyDefaultJson => kDefaultDynamicUiJson;
