import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_values.dart';
import '../../enums/household_duty.dart';
import '../../enums/work_style.dart';
import '../../models/child_profile.dart';
import '../../models/dad_profile.dart';
import '../../providers/profile_provider.dart';
import 'pages/children_page.dart';
import 'pages/duties_page.dart';
import 'pages/sport_page.dart';
import 'pages/work_style_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _lastPageIndex = AppValues.onboardingPageCount - 1;

  final _pageController = PageController();
  int _currentPage = 0;

  List<ChildProfile> _children = [];
  WorkStyle _workStyle = WorkStyle.remote;
  Set<HouseholdDuty> _duties = {};
  Set<int> _sportDays = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int delta) {
    final target = _currentPage + delta;
    if (target < 0 || target > _lastPageIndex) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _save() async {
    if (_children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('お子さんの情報を少なくとも1人追加してください')),
      );
      return;
    }

    final profile = DadProfile(
      children: _children,
      workStyle: _workStyle,
      duties: _duties,
      sportDaysOfWeek: _sportDays.toList()..sort(),
    );

    await context.read<ProfileProvider>().saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(
              currentPage: _currentPage,
              totalPages: AppValues.onboardingPageCount,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                children: [
                  ChildrenPage(
                    children: _children,
                    onChanged: (v) => setState(() => _children = v),
                  ),
                  WorkStylePage(
                    selected: _workStyle,
                    onChanged: (v) => setState(() => _workStyle = v),
                  ),
                  DutiesPage(
                    selected: _duties,
                    onChanged: (v) => setState(() => _duties = v),
                  ),
                  SportPage(
                    selectedDays: _sportDays,
                    onChanged: (v) => setState(() => _sportDays = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _animateToPage(-1),
                      child: const Text('戻る'),
                    ),
                  const Spacer(),
                  if (_currentPage < _lastPageIndex)
                    FilledButton(
                      onPressed: () => _animateToPage(1),
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
}

class _ProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  const _ProgressBar({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(totalPages, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: i <= currentPage
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
