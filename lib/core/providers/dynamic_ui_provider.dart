import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dynamic_ui/view_model/dynamic_ui_controller.dart';

// Holds the dynamic UI JSON state. The controller consumes this provider.
final dynamicUiJsonProvider = StateProvider<Map<String, dynamic>>((ref) {
  return DynamicUiController.defaultJson;
});

