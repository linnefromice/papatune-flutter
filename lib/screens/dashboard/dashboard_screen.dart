import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/disruption_type.dart';
import '../../models/disruption_log.dart';
import '../../providers/disruption_provider.dart';
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
    final log = DisruptionLog(type: type);
    context.read<DisruptionProvider>().addDisruption(log);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.label} を記録しました'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '取り消し',
          onPressed: () {
            context.read<DisruptionProvider>().removeDisruption(log.id);
          },
        ),
      ),
    );
  }

  void _onDisruptionRemove(String id) {
    context.read<DisruptionProvider>().removeDisruption(id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('記録を削除しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardHomePage(
            onDisruptionTap: _onDisruptionTap,
            onDisruptionRemove: _onDisruptionRemove,
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
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: '記録'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
