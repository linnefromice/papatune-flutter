import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/disruption_type.dart';
import '../../models/disruption_log.dart';
import '../../providers/advice_provider.dart';
import '../../providers/condition_provider.dart';
import '../../providers/disruption_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/profile_provider.dart';
import 'pages/advice_page.dart';
import 'pages/dashboard_home_page.dart';
import 'pages/review_page.dart';
import 'pages/settings_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPlan());
  }

  void _refreshPlan() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    final disruptions = context.read<DisruptionProvider>();
    final condition = context.read<ConditionProvider>();
    condition.update(disruptions.logs);
    context.read<PlanProvider>().generateTodayPlan(profile, condition.score);

    // Generate daily advice from all 5 optimization services
    context.read<AdviceProvider>().generateAdvice(
          profile: profile,
          condition: condition.score,
          recentLogs: disruptions.logs,
        );
  }

  void _onDisruptionTap(DisruptionType type) {
    context.read<DisruptionProvider>().addDisruption(DisruptionLog(type: type));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.label} を記録しました'),
        duration: const Duration(seconds: 2),
      ),
    );

    _refreshPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardHomePage(
            onDisruptionTap: _onDisruptionTap,
            onRefresh: _refreshPlan,
          ),
          const AdvicePage(),
          const ReviewPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: '今日'),
          NavigationDestination(
              icon: Icon(Icons.psychology), label: '最適化'),
          NavigationDestination(icon: Icon(Icons.analytics), label: '振り返り'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
