import 'package:flutter/material.dart';
import 'features/dynamic_ui/presentation/widgets/dynamic_ui_builder.dart';
import 'features/dynamic_ui/presentation/view_model/dynamic_ui_view_model.dart';

void main() {
  runApp(const MyApp());
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DynamicUiController _controller = DynamicUiController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: DynamicUiBuilder(json: _controller.json)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Voice input',
        child: const Icon(Icons.mic),
      ),
    );
  }
}
