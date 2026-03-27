import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/app_values.dart';
import '../../enums/household_duty.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1: Children
  final List<_ChildEntry> _childEntries = [_ChildEntry()];

  // Step 2: Work style
  WorkStyle _workStyle = WorkStyle.remote;

  // Step 3: Duties & Sport days
  final Set<HouseholdDuty> _duties = {};
  final Set<int> _sportDays = {};

  @override
  void dispose() {
    _pageController.dispose();
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

  bool _validateChildren() {
    for (int i = 0; i < _childEntries.length; i++) {
      final text = _childEntries[i].controller.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_childNickname(i)}の年齢を入力してください')),
        );
        return false;
      }
      final age = int.tryParse(text);
      if (age == null || age < 0 || age > 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${_childNickname(i)}の年齢は0〜18の数値で入力してください')),
        );
        return false;
      }
    }
    return true;
  }

  void _nextPage() {
    if (_currentPage == 0 && !_validateChildren()) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _save() async {
    final children = <ChildProfile>[];
    for (int i = 0; i < _childEntries.length; i++) {
      final age = int.parse(_childEntries[i].controller.text.trim());
      children.add(ChildProfile(
        name: _childNickname(i),
        birthDate: _birthDateFromAge(age),
      ));
    }

    final profile = DadProfile(
      children: children,
      workStyle: _workStyle,
      duties: _duties,
      sportDaysOfWeek: _sportDays.toList()..sort(),
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
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / AppValues.onboardingPageCount,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildChildrenPage(theme),
                  _buildWorkStylePage(theme),
                  _buildDutiesAndSportPage(theme),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('戻る'),
                    ),
                  const Spacer(),
                  if (_currentPage < AppValues.onboardingPageCount - 1)
                    FilledButton(
                      onPressed: _nextPage,
                      child: const Text('次へ'),
                    )
                  else
                    FilledButton(
                      onPressed: _save,
                      child: const Text('始める！'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Children ages
  Widget _buildChildrenPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        ],
      ),
    );
  }

  // Step 2: Work style
  Widget _buildWorkStylePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('働き方', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            '勤務スタイルを選んでください',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          RadioGroup<WorkStyle>(
            groupValue: _workStyle,
            onChanged: (v) => setState(() => _workStyle = v!),
            child: Column(
              children: WorkStyle.values.map((style) => ListTile(
                    title: Text(style.label),
                    leading: Radio<WorkStyle>(value: style),
                    onTap: () => setState(() => _workStyle = style),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Duties & Sport days
  Widget _buildDutiesAndSportPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text('家事 & スポーツ', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            '担当している家事を選んでください',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 32),
          Text(
            'スポーツをする曜日',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppValues.weekdayLabels.entries.map((entry) {
              final selected = _sportDays.contains(entry.key);
              return FilterChip(
                label: Text(entry.value),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _sportDays.add(entry.key) : _sportDays.remove(entry.key);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '選択しなくても OK です',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildEntry {
  final TextEditingController controller = TextEditingController();
}
