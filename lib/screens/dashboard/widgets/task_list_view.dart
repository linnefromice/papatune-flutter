import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/daily_plan.dart';
import '../../../providers/plan_provider.dart';

class TaskListView extends StatelessWidget {
  final DailyPlan plan;
  const TaskListView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${plan.completedCount} / ${plan.totalCount} 完了',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: plan.totalCount > 0
                          ? plan.completedCount / plan.totalCount
                          : 0,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...plan.tasks.map((task) {
              return ListTile(
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (_) {
                    context.read<PlanProvider>().toggleTask(task.id);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                subtitle: (task.timeSlot != null || task.durationLabel != null)
                    ? Text([
                        if (task.timeSlot != null) task.timeSlot!,
                        if (task.durationLabel != null) task.durationLabel!,
                      ].join(' / '))
                    : null,
                trailing: task.isOptional
                    ? Chip(
                        label: const Text('任意'),
                        labelStyle: theme.textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
