import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dynamic_ui/presentation/widgets/dynamic_ui_builder.dart';
import 'features/dynamic_ui/presentation/view_model/dynamic_ui_view_model.dart';
import 'features/dynamic_ui/domain/providers/ui_json_provider.dart';
import 'features/dynamic_ui/presentation/widgets/input_bottom_sheet.dart';
import 'features/dynamic_ui/domain/mocks/ui_json_mocks.dart';

void main() {
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
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: vm.resetToDefault,
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
              Expanded(
                child: Center(child: DynamicUiBuilder(json: fallback)),
              ),
            ],
          );
        },
        data: (json) => DynamicUiBuilder(json: json),
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
            if (prompt.isNotEmpty) {
              if (mode == 'create') {
                final json = getCreateMockForPrompt(prompt);
                if (json != null) {
                  ref.read(dynamicUiJsonProvider.notifier).applyJson(json);
                }
              } else {
                final curr =
                    ref.read(dynamicUiJsonProvider).value ??
                    vm.lastValidOrDefault;
                final updated = getUpdateMockForPrompt(prompt, curr);
                if (updated != null) {
                  ref.read(dynamicUiJsonProvider.notifier).applyJson(updated);
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
