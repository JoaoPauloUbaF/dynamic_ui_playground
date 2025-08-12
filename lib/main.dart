import 'package:dynamic_ui_playground/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dynamic_ui/presentation/widgets/dynamic_ui_builder.dart';
import 'features/dynamic_ui/presentation/view_model/dynamic_ui_view_model.dart';
import 'features/dynamic_ui/domain/providers/ui_json_provider.dart';
import 'features/dynamic_ui/presentation/widgets/input_bottom_sheet.dart';
import 'features/dynamic_ui/domain/mocks/ui_json_mocks.dart';
import 'features/saved_uis/domain/providers/saved_ui_provider.dart';
import 'features/saved_uis/presentation/screens/saved_uis_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dynamic_ui_playground',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC107)),
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = DynamicUiViewModel.instance..attach(ref);
    final asyncJson = vm.watchJson();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
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
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.resetToDefault(ref: ref),
          ),
        ],
      ),
      body: asyncJson.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          final fallback = vm.lastValidOrDefault;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Load error, showing last saved UI',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Expanded(child: DynamicUiBuilder(json: fallback)),
            ],
          );
        },
        data: (json) => Padding(
          padding: const EdgeInsets.only(bottom: 120.0),
          child: DynamicUiBuilder(json: json),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
