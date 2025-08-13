import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/mocks/ui_json_mocks.dart';
import '../view_model/dynamic_ui_view_model.dart';
import 'input_bottom_sheet.dart';

class NewInputFab extends ConsumerWidget {
  const NewInputFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = DynamicUiViewModel.instance..attach(ref);

    return FloatingActionButton(
      onPressed: () async {
        final currentJson = vm.getCurrentJson(ref: ref);
        final updateSuggestions = getUpdateSuggestionsForJson(currentJson);
        final result = await showModalBottomSheet(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (_) => DynamicInputBottomSheet(
            createSuggestions: kDefaultCreateSuggestions,
            updateSuggestions: updateSuggestions,
          ),
        );
        if (result is Map) {
          final mode = result['mode'] as String? ?? 'create';
          final prompt = (result['prompt'] as String?)?.trim() ?? '';
          final voice = result['voice'] == true;
          if (prompt.isNotEmpty || voice) {
            try {
              await vm.processInput(
                mode: mode,
                prompt: prompt,
                voice: voice,
                ref: ref,
              );
            } catch (e) {
              if (context.mounted) {
                final action = mode == 'create' ? 'create' : 'update';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to $action UI: $e')),
                );
              }
            }
          }
        }
      },
      tooltip: 'New input',
      child: const Icon(Icons.add_comment),
    );
  }
}
