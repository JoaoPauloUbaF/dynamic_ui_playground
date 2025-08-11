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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: asyncJson.when(
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
          data: (json) => Center(child: DynamicUiBuilder(json: json)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (_) => const DynamicInputBottomSheet(
              suggestions: kDefaultSuggestions,
              showSuggestions: true,
            ),
          );
          if (result != null && result.trim().isNotEmpty) {
            final json = getMockForPrompt(result.trim());
            if (json != null) {
              ref.read(dynamicUiJsonProvider.notifier).applyJson(json);
            }
          }
        },
        tooltip: 'New input',
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
