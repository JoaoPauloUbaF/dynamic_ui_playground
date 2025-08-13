import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/ui_json_provider.dart';
import '../../domain/mocks/ui_json_mocks.dart';
import '../view_model/dynamic_ui_view_model.dart';
import 'input_bottom_sheet.dart';

class NewInputFab extends StatelessWidget {
  const NewInputFab({super.key, required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final vm = DynamicUiViewModel.instance..attach(ref);
    return FloatingActionButton(
      onPressed: () async {
        final currentJson =
            ref.read(dynamicUiJsonProvider).value ?? vm.lastValidOrDefault;
        final updateSugs = getUpdateSuggestionsForJson(currentJson);
        final result = await showModalBottomSheet(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (_) => DynamicInputBottomSheet(
            createSuggestions: kDefaultCreateSuggestions,
            updateSuggestions: updateSugs,
          ),
        );
        if (result is Map) {
          final mode = result['mode'] as String? ?? 'create';
          final prompt = (result['prompt'] as String?)?.trim() ?? '';
          final voice = result['voice'] == true;
          if (prompt.isNotEmpty || voice) {
            if (mode == 'create') {
              // Try mocked create first; if no mock, call AI create (text/audio)
              final json = getCreateMockForPrompt(prompt);
              if (json != null) {
                DynamicUiViewModel.instance.applyNewJson(json, ref: ref);
              } else {
                try {
                  if (voice) {
                    await vm.applyCreateAudio(prompt);
                  } else {
                    await vm.applyCreateText(prompt);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create UI: $e')),
                    );
                  }
                }
              }
            } else {
              // Update flow: if mocked suggestion exists, use it; else call AI.
              final curr =
                  ref.read(dynamicUiJsonProvider).value ??
                  vm.lastValidOrDefault;
              final updated = getUpdateMockForPrompt(prompt, curr);
              if (updated != null) {
                DynamicUiViewModel.instance.applyNewJson(updated, ref: ref);
              } else {
                try {
                  if (voice) {
                    await vm.applyAudioPrompt(prompt);
                  } else {
                    await vm.applyTextPrompt(prompt);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update UI: $e')),
                    );
                  }
                }
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
