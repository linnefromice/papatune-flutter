import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_values.dart';
import '../../providers/plan_provider.dart';

class DayAssignmentScreen extends StatefulWidget {
  const DayAssignmentScreen({super.key});

  @override
  State<DayAssignmentScreen> createState() => _DayAssignmentScreenState();
}

class _DayAssignmentScreenState extends State<DayAssignmentScreen> {
  late Map<int, String?> _assignment;

  @override
  void initState() {
    super.initState();
    final current = context.read<PlanProvider>().dayAssignment;
    _assignment = {
      for (int d = 1; d <= 7; d++) d: current[d],
    };
  }

  Future<void> _save() async {
    final filtered = Map<int, String>.fromEntries(
      _assignment.entries
          .where((e) => e.value != null)
          .map((e) => MapEntry(e.key, e.value!)),
    );
    await context.read<PlanProvider>().saveDayAssignment(filtered);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = context.watch<PlanProvider>().templates;

    return Scaffold(
      appBar: AppBar(title: const Text('曜日の割り当て')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final weekday = index + 1; // 1=Mon, 7=Sun
                final dayLabel = AppValues.weekdayLabels[weekday]!;
                final selectedId = _assignment[weekday];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: weekday >= 6
                          ? theme.colorScheme.tertiaryContainer
                          : theme.colorScheme.primaryContainer,
                      child: Text(dayLabel,
                          style: TextStyle(
                            color: weekday >= 6
                                ? theme.colorScheme.onTertiaryContainer
                                : theme.colorScheme.onPrimaryContainer,
                          )),
                    ),
                    title: DropdownButton<String?>(
                      value: selectedId,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: Text('未設定',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('未設定'),
                        ),
                        ...templates.map((t) => DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text(t.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _assignment[weekday] = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('保存'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
