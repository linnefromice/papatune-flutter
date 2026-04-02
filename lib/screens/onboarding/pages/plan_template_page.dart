import 'package:flutter/material.dart';

import '../../../constants/task_templates.dart';
import '../../../models/plan_task.dart';

class PlanTemplatePage extends StatefulWidget {
  final String label;
  final List<String> defaultTasks;
  final void Function(List<PlanTask> tasks) onConfirm;

  const PlanTemplatePage({
    super.key,
    required this.label,
    required this.defaultTasks,
    required this.onConfirm,
  });

  @override
  State<PlanTemplatePage> createState() => _PlanTemplatePageState();
}

class _PlanTemplatePageState extends State<PlanTemplatePage> {
  late final List<PlanTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.defaultTasks
        .map((title) => PlanTask(title: title))
        .toList();
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  void _showAddFromCatalog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _TaskCatalogSheet(
          scrollController: scrollController,
          existingTitles: _tasks.map((t) => t.title).toSet(),
          onAdd: (title) {
            setState(() {
              _tasks.add(PlanTask(title: title));
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('${widget.label}のプラン', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'テンプレートを自分用にカスタマイズしてください',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _tasks.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  key: ValueKey(task.id),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.drag_handle,
                        color: theme.colorScheme.onSurfaceVariant),
                    title: Text(task.title),
                    trailing: IconButton(
                      onPressed: () => _removeTask(index),
                      icon: Icon(Icons.close,
                          color: theme.colorScheme.error, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddFromCatalog,
              icon: const Icon(Icons.add),
              label: const Text('タスクを追加'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCatalogSheet extends StatelessWidget {
  final ScrollController scrollController;
  final Set<String> existingTitles;
  final void Function(String title) onAdd;

  const _TaskCatalogSheet({
    required this.scrollController,
    required this.existingTitles,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('タスクを選択', style: theme.textTheme.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: TaskTemplates.categories.length,
            itemBuilder: (context, catIndex) {
              final category = TaskTemplates.categories[catIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(category.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            )),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: category.tasks.map((task) {
                      final alreadyAdded = existingTitles.contains(task);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ActionChip(
                          label: Text(task),
                          avatar: alreadyAdded
                              ? Icon(Icons.check, size: 18,
                                  color: theme.colorScheme.primary)
                              : Icon(Icons.add, size: 18,
                                  color: theme.colorScheme.onSurfaceVariant),
                          onPressed: alreadyAdded
                              ? null
                              : () {
                                  onAdd(task);
                                  Navigator.pop(context);
                                },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
