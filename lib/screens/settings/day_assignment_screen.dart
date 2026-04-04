import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_values.dart';
import '../../models/plan_template.dart';
import '../../providers/template_provider.dart';

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
    final current = context.read<TemplateProvider>().dayAssignment;
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
    await context.read<TemplateProvider>().saveDayAssignment(filtered);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = context.watch<TemplateProvider>().templates;

    return Scaffold(
      appBar: AppBar(title: const Text('曜日の割り当て')),
      body: Column(
        children: [
          if (templates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAssignButton(
                      label: '平日すべて',
                      templates: templates,
                      onAssign: (id) => setState(() {
                        for (int d = 1; d <= 5; d++) {
                          _assignment[d] = id;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAssignButton(
                      label: '休日すべて',
                      templates: templates,
                      onAssign: (id) => setState(() {
                        for (int d = 6; d <= 7; d++) {
                          _assignment[d] = id;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAssignButton(
                      label: '全曜日',
                      templates: templates,
                      onAssign: (id) => setState(() {
                        for (int d = 1; d <= 7; d++) {
                          _assignment[d] = id;
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final weekday = index + 1; // 1=Mon, 7=Sun
                final dayLabel = AppValues.weekdayLabels[weekday]!;
                // 存在しないテンプレートIDの場合は未設定に戻す
                final rawId = _assignment[weekday];
                final selectedId = (rawId != null &&
                        templates.any((t) => t.id == rawId))
                    ? rawId
                    : null;

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

class _QuickAssignButton extends StatelessWidget {
  final String label;
  final List<PlanTemplate> templates;
  final void Function(String templateId) onAssign;

  const _QuickAssignButton({
    required this.label,
    required this.templates,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showPicker(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$label に割り当てるテンプレート',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ...templates.map((t) => ListTile(
                  title: Text(t.name),
                  onTap: () {
                    onAssign(t.id);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
