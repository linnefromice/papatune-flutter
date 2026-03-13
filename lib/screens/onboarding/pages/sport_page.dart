import 'package:flutter/material.dart';

import '../../../constants/app_values.dart';

class SportPage extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onChanged;

  const SportPage({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('スポーツの予定', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('週に何曜日にスポーツをしますか？',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppValues.weekdayLabels.entries.map((entry) {
              return FilterChip(
                label: Text(entry.value),
                selected: selectedDays.contains(entry.key),
                onSelected: (v) {
                  final updated = Set<int>.from(selectedDays);
                  if (v) {
                    updated.add(entry.key);
                  } else {
                    updated.remove(entry.key);
                  }
                  onChanged(updated);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (selectedDays.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'スポーツの予定がなくても大丈夫です。日常的な運動メニューを提案します。',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
