import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/advice_provider.dart';
import 'advice/autonomic_section.dart';
import 'advice/exercise_section.dart';
import 'advice/meal_section.dart';
import 'advice/sleep_recovery_section.dart';
import 'advice/time_roi_section.dart';

class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final advice = context.watch<AdviceProvider>().todayAdvice;

    if (advice == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_alt,
                    size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('アドバイスを生成中...',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('ホーム画面でコンディションを更新してください',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('最適化アドバイス', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${advice.mode.description} | ${advice.mode.label}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: advice.mode.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(icon: Icon(Icons.fitness_center), text: '運動'),
                Tab(icon: Icon(Icons.bed), text: '睡眠回復'),
                Tab(icon: Icon(Icons.restaurant), text: '食事'),
                Tab(icon: Icon(Icons.psychology), text: '自律神経'),
                Tab(icon: Icon(Icons.timer), text: '時間ROI'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ExerciseSection(advice: advice.exercise),
                  SleepRecoverySection(advice: advice.sleepRecovery),
                  MealSection(advice: advice.meal),
                  AutonomicSection(advice: advice.autonomic),
                  TimeRoiSection(advice: advice.timeRoi),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
