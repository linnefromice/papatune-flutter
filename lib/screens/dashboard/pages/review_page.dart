import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_values.dart';
import '../../../enums/plan_mode.dart';
import '../../../providers/disruption_provider.dart';
import '../../../providers/plan_provider.dart';
import '../widgets/stat_row.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plans =
        context.watch<PlanProvider>().plansForLastNDays(AppValues.reviewPeriodDays);
    final disruptions = context.watch<DisruptionProvider>();

    final last7dDisruptions = disruptions.logsForDateRange(
      DateTime.now().subtract(
          const Duration(days: AppValues.reviewPeriodDays)),
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
          _WeeklySummaryCard(
            disruptionCount: last7dDisruptions.length,
            daysAdapted: daysAdapted,
            daysWithPlans: daysWithPlans,
          ),
          const SizedBox(height: 12),
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

class _PlanModeHistoryCard extends StatelessWidget {
  final List plans;
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
