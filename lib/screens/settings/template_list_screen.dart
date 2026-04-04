import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_values.dart';
import '../../models/plan_template.dart';
import '../../providers/template_provider.dart';
import 'template_edit_screen.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templateProvider = context.watch<TemplateProvider>();
    final templates = templateProvider.templates;

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
                final assignedDays = templateProvider.dayAssignment.entries
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
                    onLongPress: () =>
                        _showActions(context, template),
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

  void _showActions(BuildContext context, PlanTemplate template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('複製'),
              onTap: () {
                Navigator.pop(context);
                _duplicate(context, template);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('削除',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, template);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _duplicate(BuildContext context, PlanTemplate template) {
    final copy = PlanTemplate(
      name: '${template.name}のコピー',
      tasks: List.of(template.tasks),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplateEditScreen(template: copy, isDuplicate: true),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, PlanTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('テンプレートを削除'),
        content: const Text('このテンプレートを削除しますか？割り当てられている曜日も解除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TemplateProvider>().deleteTemplate(template.id);
    }
  }
}
