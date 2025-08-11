import 'package:flutter/material.dart';

class InputSuggestions extends StatelessWidget {
  const InputSuggestions({super.key, required this.onSelected, required this.suggestions});

  final ValueChanged<String> onSelected;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
children: suggestions
              .map(
                (e) => ActionChip(
                  label: Text(e, overflow: TextOverflow.ellipsis),
                  onPressed: () => onSelected(e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

