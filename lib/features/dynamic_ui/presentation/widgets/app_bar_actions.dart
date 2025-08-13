import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/view_model/dynamic_ui_view_model.dart';
import '../../../saved_uis/domain/providers/saved_ui_provider.dart';
import '../../../saved_uis/presentation/screens/saved_uis_screen.dart';
import '../../domain/providers/ui_json_provider.dart';

class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key, required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final vm = DynamicUiViewModel.instance..attach(ref);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Undo',
          icon: const Icon(Icons.undo),
          onPressed: vm.canUndo ? () => vm.undo(ref: ref) : null,
        ),
        IconButton(
          tooltip: 'Redo',
          icon: const Icon(Icons.redo),
          onPressed: vm.canRedo ? () => vm.redo(ref: ref) : null,
        ),
        IconButton(
          tooltip: 'Saved UIs',
          icon: const Icon(Icons.bookmarks),
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SavedUisScreen()));
          },
        ),
        IconButton(
          tooltip: 'Save UI',
          icon: const Icon(Icons.bookmark_add),
          onPressed: () async {
            final textController = TextEditingController();
            final name = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Save current UI'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Name (optional)',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(ctx).pop(textController.text.trim()),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            if (name != null) {
              final currentJson =
                  ref.read(dynamicUiJsonProvider).value ??
                  vm.lastValidOrDefault;
              final notifier = ref.read(savedUiListProvider.notifier);
              final saved = await notifier.saveCurrent(name, currentJson);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved "${saved.name}"')),
                );
              }
            }
          },
        ),
        IconButton(
          tooltip: 'Reset',
          icon: const Icon(Icons.refresh),
          onPressed: () => vm.resetToDefault(ref: ref),
        ),
      ],
    );
  }
}
