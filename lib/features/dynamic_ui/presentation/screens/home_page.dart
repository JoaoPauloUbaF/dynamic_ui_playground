import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/view_model/dynamic_ui_view_model.dart';
import '../widgets/dynamic_ui_builder.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/new_input_fab.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = DynamicUiViewModel.instance..attach(ref);
    final asyncJson = vm.watchJson();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [AppBarActions()],
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
      floatingActionButton: NewInputFab(),
    );
  }
}
