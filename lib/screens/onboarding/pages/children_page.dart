import 'package:flutter/material.dart';

import '../../../constants/app_values.dart';
import '../../../models/child_profile.dart';

class ChildrenPage extends StatefulWidget {
  final List<ChildProfile> children;
  final ValueChanged<List<ChildProfile>> onChanged;

  const ChildrenPage({
    super.key,
    required this.children,
    required this.onChanged,
  });

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addChild() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _birthDate == null) return;

    final updated = [
      ...widget.children,
      ChildProfile(name: name, birthDate: _birthDate!),
    ];
    widget.onChanged(updated);
    _nameController.clear();
    setState(() => _birthDate = null);
  }

  void _removeChild(int index) {
    final updated = [...widget.children]..removeAt(index);
    widget.onChanged(updated);
  }

  Future<void> _pickBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      firstDate: DateTime(AppValues.childFirstDateYear),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('お子さんの情報', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('お子さんの年齢から「カオス度」を判定します',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '名前（ニックネーム可）',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _pickBirthDate,
                child: Text(_birthDate == null
                    ? '生年月日'
                    : '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}'),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addChild,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.children.isEmpty
                ? Center(
                    child: Text('まだお子さんが追加されていません',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)))
                : ListView.builder(
                    itemCount: widget.children.length,
                    itemBuilder: (context, index) {
                      final child = widget.children[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.child_care),
                          title: Text(child.name),
                          subtitle: Text(child.ageLabel),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeChild(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
