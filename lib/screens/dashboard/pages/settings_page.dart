import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/dad_profile.dart';
import '../../../providers/template_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../settings/day_assignment_screen.dart';
import '../../settings/template_list_screen.dart';

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
            _TemplateManagementCard(),
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
            Text('プロフィール', style: theme.textTheme.titleLarge),
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
              value: profile.duties.map((d) => d.label).join(', '),
            ),
            _ProfileRow(label: 'スポーツ', value: profile.sportDaysLabel),
            _ProfileRow(label: 'カオス度', value: '${profile.chaosLevel}/10'),
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

class _TemplateManagementCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templateCount = context.watch<TemplateProvider>().templates.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('テンプレート管理', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('テンプレート一覧'),
              subtitle: Text('$templateCount 件'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TemplateListScreen()),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('曜日の割り当て'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DayAssignmentScreen()),
              ),
            ),
          ],
        ),
      ),
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
