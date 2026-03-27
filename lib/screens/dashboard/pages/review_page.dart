import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_values.dart';
import '../../../enums/disruption_type.dart';
import '../../../enums/plan_mode.dart';
import '../../../models/daily_plan.dart';
import '../../../models/disruption_log.dart';
import '../../../providers/disruption_provider.dart';
import '../../../providers/plan_provider.dart';
import '../widgets/stat_row.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plans = context
        .watch<PlanProvider>()
        .plansForLastNDays(AppValues.reviewPeriodDays);
    final disruptions = context.watch<DisruptionProvider>();

    final last7dDisruptions = disruptions.logsForDateRange(
      DateTime.now()
          .subtract(const Duration(days: AppValues.reviewPeriodDays)),
      DateTime.now(),
    );

    final daysWithPlans = plans.length;
    final daysAdapted =
        plans.where((p) => p.mode != PlanMode.planA).length;
    final adaptabilityScore = daysWithPlans > 0
        ? ((daysWithPlans / AppValues.reviewPeriodDays) * 100).round()
        : 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('週次レビュー', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          _AdaptabilityScoreCard(
            score: adaptabilityScore,
            daysWithPlans: daysWithPlans,
          ),
          const SizedBox(height: 12),
          _TaskCompletionCard(plans: plans),
          const SizedBox(height: 12),
          _WeeklySummaryCard(
            disruptionCount: last7dDisruptions.length,
            daysAdapted: daysAdapted,
            daysWithPlans: daysWithPlans,
          ),
          const SizedBox(height: 12),
          if (last7dDisruptions.isNotEmpty)
            _DisruptionBreakdownCard(disruptions: last7dDisruptions),
          if (last7dDisruptions.isNotEmpty) const SizedBox(height: 12),
          if (plans.isNotEmpty) _PlanModeHistoryCard(plans: plans),
          const SizedBox(height: 16),
          _FeedbackCard(daysAdapted: daysAdapted),
        ],
      ),
    );
  }
}

class _AdaptabilityScoreCard extends StatelessWidget {
  final int score;
  final int daysWithPlans;
  const _AdaptabilityScoreCard({
    required this.score,
    required this.daysWithPlans,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('適応力スコア', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              '$score%',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('過去${AppValues.reviewPeriodDays}日間のうち $daysWithPlans 日プランを実行'),
          ],
        ),
      ),
    );
  }
}

class _TaskCompletionCard extends StatelessWidget {
  final List<DailyPlan> plans;
  const _TaskCompletionCard({required this.plans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int totalTasks = 0;
    int completedTasks = 0;
    for (final plan in plans) {
      totalTasks += plan.totalCount;
      completedTasks += plan.completedCount;
    }

    final rate = totalTasks > 0
        ? ((completedTasks / totalTasks) * 100).round()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('タスク完了率', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$rate%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$completedTasks / $totalTasks タスク完了'),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final int disruptionCount;
  final int daysAdapted;
  final int daysWithPlans;
  const _WeeklySummaryCard({
    required this.disruptionCount,
    required this.daysAdapted,
    required this.daysWithPlans,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今週のサマリー', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            StatRow(label: 'イレギュラー発生', value: '$disruptionCount回'),
            StatRow(label: 'プラン切替（適応）', value: '$daysAdapted日'),
            StatRow(
                label: '記録日数',
                value: '$daysWithPlans / ${AppValues.reviewPeriodDays}日'),
          ],
        ),
      ),
    );
  }
}

class _DisruptionBreakdownCard extends StatelessWidget {
  final List<DisruptionLog> disruptions;
  const _DisruptionBreakdownCard({required this.disruptions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Count by type
    final counts = <DisruptionType, int>{};
    for (final log in disruptions) {
      counts[log.type] = (counts[log.type] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('カオスイベント内訳', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...sorted.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(entry.key.icon, size: 20,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key.label)),
                      Text(
                        '${entry.value}回',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PlanModeHistoryCard extends StatelessWidget {
  final List<DailyPlan> plans;
  const _PlanModeHistoryCard({required this.plans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('日別プランモード', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...plans.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: p.mode.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(p.dateKey),
                    const SizedBox(width: 8),
                    Text(p.mode.description,
                        style: TextStyle(color: p.mode.color)),
                    const Spacer(),
                    Text(
                      '${p.completedCount}/${p.totalCount}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final int daysAdapted;
  const _FeedbackCard({required this.daysAdapted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          daysAdapted > 0
              ? '今週は$daysAdapted日プランを柔軟に切り替えました。予定が崩れても適応できるあなたの姿勢は、お子さんにとって最高のお手本です！'
              : '今週は順調な1週間でした！余裕がある時こそ自分への投資を忘れずに。',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
