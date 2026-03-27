import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_values.dart';
import '../../../enums/household_duty.dart';
import '../../../enums/work_style.dart';
import '../../../models/child_profile.dart';
import '../../../models/dad_profile.dart';
import '../../../providers/profile_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('設定', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (profile != null) ...[
            _ProfileCard(profile: profile),
            const SizedBox(height: 16),
            _ResetButton(),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final DadProfile profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('プロフィール', style: theme.textTheme.titleLarge),
                IconButton(
                  onPressed: () => _showEditSheet(context),
                  icon: const Icon(Icons.edit),
                  tooltip: '編集',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProfileRow(
              label: 'お子さん',
              value: profile.children
                  .map((c) => '${c.name}(${c.ageLabel})')
                  .join(', '),
            ),
            _ProfileRow(label: '仕事', value: profile.workStyle.label),
            _ProfileRow(
              label: '家事',
              value: profile.duties.isEmpty
                  ? 'なし'
                  : profile.duties.map((d) => d.label).join(', '),
            ),
            _ProfileRow(label: 'スポーツ', value: profile.sportDaysLabel),
            _ProfileRow(label: 'カオス度', value: '${profile.chaosLevel}/10'),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProfileEditSheet(profile: profile),
    );
  }
}

class _ProfileEditSheet extends StatefulWidget {
  final DadProfile profile;
  const _ProfileEditSheet({required this.profile});

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late WorkStyle _workStyle;
  late Set<HouseholdDuty> _duties;
  late Set<int> _sportDays;
  late List<ChildProfile> _children;

  @override
  void initState() {
    super.initState();
    _workStyle = widget.profile.workStyle;
    _duties = Set.from(widget.profile.duties);
    _sportDays = Set.from(widget.profile.sportDaysOfWeek);
    _children = List.from(widget.profile.children);
  }

  Future<void> _save() async {
    final updatedProfile = DadProfile(
      children: _children,
      workStyle: _workStyle,
      duties: _duties,
      sportDaysOfWeek: _sportDays.toList()..sort(),
      createdAt: widget.profile.createdAt,
    );

    await context.read<ProfileProvider>().saveProfile(updatedProfile);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _addChild() {
    setState(() {
      final index = _children.length + 1;
      _children.add(ChildProfile(
        name: '子ども$index',
        birthDate: DateTime(DateTime.now().year - 1, 1, 1),
      ));
    });
  }

  void _removeChild(int index) {
    if (_children.length <= 1) return;
    setState(() {
      _children.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: ListView(
          controller: scrollController,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('プロフィール編集', style: theme.textTheme.titleLarge),
                FilledButton(
                  onPressed: _save,
                  child: const Text('保存'),
                ),
              ],
            ),
            const Divider(height: 24),

            // Children section
            Text('お子さん', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._children.asMap().entries.map((entry) {
              final i = entry.key;
              final child = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.child_care,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${child.name}（${child.ageLabel}）'),
                    ),
                    if (_children.length > 1)
                      IconButton(
                        onPressed: () => _removeChild(i),
                        icon: Icon(Icons.remove_circle_outline,
                            color: theme.colorScheme.error, size: 20),
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addChild,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('子どもを追加'),
            ),
            const Divider(height: 24),

            // Work style section
            Text('勤務スタイル', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioGroup<WorkStyle>(
              groupValue: _workStyle,
              onChanged: (v) => setState(() => _workStyle = v!),
              child: Column(
                children: WorkStyle.values
                    .map((style) => ListTile(
                          dense: true,
                          title: Text(style.label),
                          leading: Radio<WorkStyle>(value: style),
                          onTap: () => setState(() => _workStyle = style),
                        ))
                    .toList(),
              ),
            ),
            const Divider(height: 24),

            // Duties section
            Text('担当家事', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HouseholdDuty.values.map((duty) {
                final selected = _duties.contains(duty);
                return FilterChip(
                  avatar: Icon(duty.icon, size: 18),
                  label: Text(duty.label),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    v ? _duties.add(duty) : _duties.remove(duty);
                  }),
                );
              }).toList(),
            ),
            const Divider(height: 24),

            // Sport days section
            Text('スポーツ曜日', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppValues.weekdayLabels.entries.map((entry) {
                final selected = _sportDays.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    v
                        ? _sportDays.add(entry.key)
                        : _sportDays.remove(entry.key);
                  }),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: $value'),
    );
  }
}

class _ResetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmReset(context),
      icon: const Icon(Icons.restart_alt),
      label: const Text('プロフィールをリセット'),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('プロフィールをリセット'),
        content: const Text('すべてのデータが削除されます。よろしいですか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('リセット')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProfileProvider>().clearProfile();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }
}
