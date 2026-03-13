import 'package:flutter/material.dart';

import '../../../enums/household_duty.dart';

class DutiesPage extends StatelessWidget {
  final Set<HouseholdDuty> selected;
  final ValueChanged<Set<HouseholdDuty>> onChanged;

  const DutiesPage({
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
          Text('担当している家事', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('スケジュールに組み込む家事を選択してください',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: HouseholdDuty.values.map((duty) {
                return Card(
                  child: CheckboxListTile(
                    secondary: Icon(duty.icon),
                    title: Text(duty.label),
                    value: selected.contains(duty),
                    onChanged: (checked) {
                      final updated = Set<HouseholdDuty>.from(selected);
                      if (checked!) {
                        updated.add(duty);
                      } else {
                        updated.remove(duty);
                      }
                      onChanged(updated);
                    },
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
