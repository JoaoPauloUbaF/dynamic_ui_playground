import 'package:flutter/material.dart';
import 'input_suggestions.dart';

class DynamicInputBottomSheet extends StatefulWidget {
  const DynamicInputBottomSheet({super.key, this.showSuggestions = true, this.suggestions = const []});

  final bool showSuggestions;
  final List<String> suggestions;

  @override
  State<DynamicInputBottomSheet> createState() => _DynamicInputBottomSheetState();
}

class _DynamicInputBottomSheetState extends State<DynamicInputBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (widget.showSuggestions)
                InputSuggestions(
                  suggestions: widget.suggestions,
                  onSelected: (value) {
                    _controller.text = value;
                    _controller.selection = TextSelection(baseOffset: value.length, extentOffset: value.length);
                  },
                ),
              if (widget.showSuggestions) const SizedBox(height: 8),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Type a prompt...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // TODO: handle voice input trigger
                      },
                      icon: const Icon(Icons.mic),
                      tooltip: 'Voice input',
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(context).pop(text);
                        }
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

