import 'package:flutter/material.dart';

import '../../../enums/work_style.dart';

class WorkStylePage extends StatelessWidget {
  final WorkStyle selected;
  final ValueChanged<WorkStyle> onChanged;

  const WorkStylePage({
    super.key,
    required this.selected,
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
          Text('仕事のスタイル', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('リカバリー方針を決定するために必要です',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          RadioGroup<WorkStyle>(
            groupValue: selected,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            child: Column(
              children: WorkStyle.values.map((style) {
                return Card(
                  child: RadioListTile<WorkStyle>(
                    title: Text(style.label),
                    value: style,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
