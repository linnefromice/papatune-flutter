import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../enums/work_style.dart';
import '../../models/child_profile.dart';
import '../../models/dad_profile.dart';
import '../../providers/profile_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<_ChildEntry> _childEntries = [_ChildEntry()];

  @override
  void dispose() {
    for (final entry in _childEntries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  void _addChild() {
    setState(() {
      _childEntries.add(_ChildEntry());
    });
  }

  void _removeChild(int index) {
    if (_childEntries.length <= 1) return;
    setState(() {
      _childEntries[index].controller.dispose();
      _childEntries.removeAt(index);
    });
  }

  Future<void> _save() async {
    // Validate: at least one child with a valid age
    final children = <ChildProfile>[];
    for (int i = 0; i < _childEntries.length; i++) {
      final text = _childEntries[i].controller.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_childNickname(i)}の年齢を入力してください')),
        );
        return;
      }
      final age = int.tryParse(text);
      if (age == null || age < 0 || age > 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${_childNickname(i)}の年齢は0〜18の数値で入力してください')),
        );
        return;
      }
      children.add(ChildProfile(
        name: _childNickname(i),
        birthDate: _birthDateFromAge(age),
      ));
    }

    final profile = DadProfile(
      children: children,
      workStyle: WorkStyle.remote,
      duties: {},
      sportDaysOfWeek: [],
    );

    await context.read<ProfileProvider>().saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  String _childNickname(int index) => '子ども${index + 1}';

  DateTime _birthDateFromAge(int age) {
    final now = DateTime.now();
    return DateTime(now.year - age, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('ようこそ！', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'お子さんの年齢を教えてください',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _childEntries.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.child_care,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            _childNickname(index),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _childEntries[index].controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '年齢',
                                suffixText: '歳',
                                isDense: true,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (_childEntries.length > 1)
                            IconButton(
                              onPressed: () => _removeChild(index),
                              icon: Icon(Icons.remove_circle_outline,
                                  color: theme.colorScheme.error),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: _addChild,
                  icon: const Icon(Icons.add),
                  label: const Text('子どもを追加'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('始める！'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '他の設定はあとから変更できます',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildEntry {
  final TextEditingController controller = TextEditingController();
}
