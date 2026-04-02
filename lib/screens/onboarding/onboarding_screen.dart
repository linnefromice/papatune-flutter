import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/task_templates.dart';
import '../../enums/plan_mode.dart';
import '../../enums/work_style.dart';
import '../../models/child_profile.dart';
import '../../models/dad_profile.dart';
import '../../models/daily_plan.dart';
import '../../models/plan_task.dart';
import '../../providers/plan_provider.dart';
import '../../providers/profile_provider.dart';
import 'pages/plan_template_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _totalPages = 3;

  final _pageController = PageController();
  final List<_ChildEntry> _childEntries = [_ChildEntry()];
  int _currentPage = 0;
  List<PlanTask>? _weekdayTasks;

  @override
  void dispose() {
    _pageController.dispose();
    for (final entry in _childEntries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  // --- Step 1: Children ---

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

  String _childNickname(int index) => '子ども${index + 1}';

  DateTime _birthDateFromAge(int age) {
    final now = DateTime.now();
    return DateTime(now.year - age, 1, 1);
  }

  void _goToNextPage() {
    // Validate children
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
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // --- Step 2: Weekday plan ---

  void _onWeekdayConfirmed(List<PlanTask> tasks) {
    _weekdayTasks = tasks;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // --- Step 3: Weekend plan → finish ---

  Future<void> _onWeekendConfirmed(List<PlanTask> tasks) async {
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
      workStyle: WorkStyle.remote,
      duties: {},
      sportDaysOfWeek: [],
    );

    await context.read<ProfileProvider>().saveProfile(profile);

    if (!mounted) return;

    final planProvider = context.read<PlanProvider>();

    // Save both templates
    await planProvider.saveWeekdayTemplate(_weekdayTasks!);
    await planProvider.saveWeekendTemplate(tasks);

    // Set today's plan based on current day of week
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday ||
        now.weekday == DateTime.sunday;
    final todayTasks = isWeekend ? tasks : _weekdayTasks!;

    final todayPlan = DailyPlan(
      date: now,
      mode: PlanMode.planA,
      tasks: todayTasks.map((t) => PlanTask(title: t.title)).toList(),
    );
    planProvider.setTodayPlan(todayPlan);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Step indicator
              Row(
                children: List.generate(_totalPages, (i) {
                  return Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                    child: _StepDot(active: _currentPage == i),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  children: [
                    _buildChildrenPage(theme),
                    PlanTemplatePage(
                      label: '平日',
                      defaultTasks: TaskTemplates.weekdayDefaults,
                      confirmButtonText: '次へ：休日プラン',
                      onConfirm: _onWeekdayConfirmed,
                    ),
                    PlanTemplatePage(
                      label: '休日',
                      defaultTasks: TaskTemplates.weekendDefaults,
                      confirmButtonText: 'このプランで始める！',
                      onConfirm: _onWeekendConfirmed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenPage(ThemeData theme) {
    return Column(
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
            onPressed: _goToNextPage,
            child: const Text('次へ'),
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
    );
  }
}

class _ChildEntry {
  final TextEditingController controller = TextEditingController();
}

class _StepDot extends StatelessWidget {
  final bool active;
  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
