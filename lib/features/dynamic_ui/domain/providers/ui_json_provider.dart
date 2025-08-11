import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Default JSON used when provider is first loaded or reset.
const Map<String, dynamic> kDefaultDynamicUiJson = {
  'type': 'column',
  'props': {'mainAxisAlignment': 'center', 'crossAxisAlignment': 'center'},
  'children': [
    {
      'type': 'text',
      'props': {
        'value': 'Dynamic UI (Async)',
        'size': 22,
        'align': 'center',
        'fontFamily': 'Inter',
      },
    },
    {
      'type': 'sizedBox',
      'props': {'height': 12},
    },
    {
      'type': 'row',
      'props': {
        'mainAxisAlignment': 'spaceEvenly',
        'crossAxisAlignment': 'center',
        'spacing': 8,
      },
      'children': [
        {
          'type': 'icon',
          'props': {
            'icon': 'mic',
            'size': 28,
            'color': '#FF6200EE',
            'material3': true,
            'm3Style': 'outlined',
            'm3Weight': 400,
            'm3OpticalSize': 48,
          },
        },
        {
          'type': 'text',
          'props': {'value': 'Async content loaded', 'size': 16},
        },
      ],
    },
  ],
};

/// Async notifier that simulates fetching the JSON from a backend.
/// Exposes a reset method to invalidate and restore defaults.
class DynamicUiJsonNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Return default initially
    return kDefaultDynamicUiJson;
  }

  Future<void> refreshFromServer() async {
    state = const AsyncLoading();
    // Simulate a fetch with slight variation
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = AsyncData({
      ...kDefaultDynamicUiJson,
      'children': [
        ...kDefaultDynamicUiJson['children'] as List,
        {
          'type': 'text',
          'props': {
            'value': 'Fetched at ${DateTime.now().toIso8601String()}',
            'size': 12,
            'align': 'center',
          },
        },
      ],
    });
  }

  void resetToDefault() {
    state = const AsyncLoading();
    // No delay needed, but we keep a micro delay to yield the event loop
    Future<void>.microtask(
      () => state = const AsyncData(kDefaultDynamicUiJson),
    );
  }
}

final dynamicUiJsonProvider =
    AsyncNotifierProvider<DynamicUiJsonNotifier, Map<String, dynamic>>(
      () => DynamicUiJsonNotifier(),
    );
