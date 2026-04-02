import 'package:flutter/material.dart';

import '../../../constants/task_templates.dart';
import '../../../models/plan_task.dart';

class PlanTemplatePage extends StatefulWidget {
  final String label;
  final List<String> defaultTasks;
  final String confirmButtonText;
  final void Function(List<PlanTask> tasks) onConfirm;

  const PlanTemplatePage({
    super.key,
    required this.label,
    required this.defaultTasks,
    this.confirmButtonText = '次へ',
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

  void _showTimePicker(int index) {
    final task = _tasks[index];
    // Parse existing timeSlot or default to 08:00
    int hour = 8;
    int minute = 0;
    if (task.timeSlot != null) {
      final parts = task.timeSlot!.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final timeLabel =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

          void addMinutes(int delta) {
            setSheetState(() {
              var total = hour * 60 + minute + delta;
              total = total.clamp(0, 23 * 60 + 50);
              hour = total ~/ 60;
              minute = total % 60;
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(task.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.outlined(
                      onPressed: (hour > 0 || minute > 0)
                          ? () => addMinutes(-10)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        timeLabel,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: (hour < 23 || minute < 50)
                          ? () => addMinutes(10)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['06:00', '07:00', '08:00', '12:00', '18:00', '21:00']
                      .map((t) {
                    return ChoiceChip(
                      label: Text(t),
                      selected: timeLabel == t,
                      onSelected: (_) {
                        final parts = t.split(':');
                        setSheetState(() {
                          hour = int.parse(parts[0]);
                          minute = int.parse(parts[1]);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _tasks[index] = PlanTask(
                              id: task.id,
                              title: task.title,
                              timeSlot: null,
                            );
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('時刻なし'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _tasks[index] = PlanTask(
                              id: task.id,
                              title: task.title,
                              timeSlot: timeLabel,
                            );
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('設定'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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
          initialExistingTitles: _tasks.map((t) => t.title).toSet(),
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
                    subtitle: task.timeSlot != null
                        ? Text(task.timeSlot!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ))
                        : null,
                    onTap: () => _showTimePicker(index),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 16,
                            color: task.timeSlot != null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _removeTask(index),
                          icon: Icon(Icons.close,
                              color: theme.colorScheme.error, size: 20),
                        ),
                      ],
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _tasks.isEmpty
                  ? null
                  : () => widget.onConfirm(List.of(_tasks)),
              child: Text(widget.confirmButtonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCatalogSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Set<String> initialExistingTitles;
  final void Function(String title) onAdd;

  const _TaskCatalogSheet({
    required this.scrollController,
    required this.initialExistingTitles,
    required this.onAdd,
  });

  @override
  State<_TaskCatalogSheet> createState() => _TaskCatalogSheetState();
}

class _TaskCatalogSheetState extends State<_TaskCatalogSheet> {
  late final Set<String> _addedTitles;

  @override
  void initState() {
    super.initState();
    _addedTitles = Set.of(widget.initialExistingTitles);
  }

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
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('完了'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
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
                      final alreadyAdded = _addedTitles.contains(task);
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
                                  widget.onAdd(task);
                                  setState(() {
                                    _addedTitles.add(task);
                                  });
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
