import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/ui_json_provider.dart';

/// Singleton ViewModel that bridges UI (WidgetRef) and the async JSON provider.
class DynamicUiViewModel {
  DynamicUiViewModel._internal();
  static final DynamicUiViewModel instance = DynamicUiViewModel._internal();

  WidgetRef? _ref;
  Map<String, dynamic>? _lastValid;

  void attach(WidgetRef ref) {
    _ref = ref;
  }

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
  Map<String, dynamic> get lastValidOrDefault => _lastValid ?? kDefaultDynamicUiJson;

  /// Trigger a refresh (simulated fetch).
  Future<void> refresh() async {
    final ref = _ref;
    if (ref == null) return;
    await ref.read(dynamicUiJsonProvider.notifier).refreshFromServer();
  }

  /// Reset back to default JSON.
  void resetToDefault() {
    final ref = _ref;
    if (ref == null) return;
    ref.read(dynamicUiJsonProvider.notifier).resetToDefault();
  }
}

// Kept for backward-compatibility in case anything references default JSON here.
Map<String, dynamic> get legacyDefaultJson => kDefaultDynamicUiJson;
