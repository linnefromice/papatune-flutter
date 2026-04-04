import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/task_templates.dart';
import '../../models/plan_task.dart';
import '../../models/plan_template.dart';
import '../../providers/template_provider.dart';
import '../onboarding/pages/plan_template_page.dart';

class TemplateEditScreen extends StatefulWidget {
  final PlanTemplate? template;
  final bool isDuplicate;

  const TemplateEditScreen({
    super.key,
    this.template,
    this.isDuplicate = false,
  });

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool get _isNew => widget.template == null || widget.isDuplicate;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.template?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave(List<PlanTask> tasks) async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final templateProvider = context.read<TemplateProvider>();

    final templateTasks = tasks
        .map((t) => TemplateTask(title: t.title, timeSlot: t.timeSlot))
        .toList();

    if (_isNew) {
      final template = PlanTemplate(name: name, tasks: templateTasks);
      await templateProvider.addTemplate(template);
    } else {
      final updated =
          widget.template!.copyWith(name: name, tasks: templateTasks);
      await templateProvider.updateTemplate(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _onDelete() async {
    if (_isNew) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テンプレートを削除'),
        content: const Text('このテンプレートを削除しますか？割り当てられている曜日も解除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<TemplateProvider>().deleteTemplate(widget.template!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? '新しいテンプレート' : 'テンプレート編集'),
        actions: [
          if (!_isNew)
            IconButton(
              onPressed: _onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'テンプレート名',
                  hintText: '例: 平日、在宅勤務日、出社日',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '名前を入力してください' : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.template != null
                  ? PlanTemplatePage(
                      key: ValueKey(widget.template!.id),
                      label: '',
                      showHeader: false,
                      initialPlanTasks: widget.template!.tasks
                          .map((t) =>
                              PlanTask(title: t.title, timeSlot: t.timeSlot))
                          .toList(),
                      confirmButtonText: '保存',
                      onConfirm: _onSave,
                    )
                  : PlanTemplatePage(
                      key: const ValueKey('new'),
                      label: '',
                      showHeader: false,
                      defaultTasks: TaskTemplates.weekdayDefaults,
                      confirmButtonText: '保存',
                      onConfirm: _onSave,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
