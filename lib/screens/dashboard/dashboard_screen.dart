import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/disruption_type.dart';
import '../../models/disruption_log.dart';
import '../../providers/condition_provider.dart';
import '../../providers/disruption_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/profile_provider.dart';
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

  void _onDisruptionTap(DisruptionType type) {
    context.read<DisruptionProvider>().addDisruption(DisruptionLog(type: type));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.label} を記録しました'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ConditionProvider は ProxyProvider 経由で DisruptionProvider の
    // 変更を自動検知するため、watch するだけでリアクティブに更新される
    final profile = context.watch<ProfileProvider>().profile;
    final condition = context.watch<ConditionProvider>().score;

    if (profile != null) {
      // build 内で他 Provider の状態を変更するため、
      // フレーム終了後に実行して無限ループを防ぐ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<PlanProvider>().generateTodayPlan(profile, condition);
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardHomePage(
            onDisruptionTap: _onDisruptionTap,
          ),
          const ReviewPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: '今日'),
          NavigationDestination(icon: Icon(Icons.analytics), label: '振り返り'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
