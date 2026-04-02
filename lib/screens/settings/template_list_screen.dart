import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_values.dart';
import '../../models/plan_template.dart';
import '../../providers/plan_provider.dart';
import 'template_edit_screen.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planProvider = context.watch<PlanProvider>();
    final templates = planProvider.templates;

    return Scaffold(
      appBar: AppBar(title: const Text('テンプレート一覧')),
      body: templates.isEmpty
          ? Center(
              child: Text('テンプレートがありません',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final assignedDays = planProvider.dayAssignment.entries
                    .where((e) => e.value == template.id)
                    .map((e) => AppValues.weekdayLabels[e.key]!)
                    .toList();
                final daysLabel = assignedDays.isEmpty
                    ? '未割り当て'
                    : '${assignedDays.join("・")} / ${template.tasks.length} タスク';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(template.name),
                    subtitle: Text(daysLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openEdit(context, template),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEdit(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEdit(BuildContext context, PlanTemplate? template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplateEditScreen(template: template),
      ),
    );
  }
}
