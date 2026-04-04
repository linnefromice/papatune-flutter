import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../enums/disruption_type.dart';
import '../../../models/disruption_log.dart';
import '../../../providers/condition_provider.dart';
import '../../../providers/disruption_provider.dart';
import '../../../providers/plan_provider.dart';
import '../../../services/coach_message_service.dart';
import '../widgets/coach_message_card.dart';
import '../widgets/condition_score_card.dart';
import '../widgets/plan_mode_indicator.dart';
import '../widgets/quick_input_bar.dart';
import '../widgets/task_list_view.dart';

class DashboardHomePage extends StatelessWidget {
  final void Function(DisruptionType) onDisruptionTap;
  final void Function(String id) onDisruptionRemove;
  final CoachMessageService _coachService;

  DashboardHomePage({
    super.key,
    required this.onDisruptionTap,
    required this.onDisruptionRemove,
    CoachMessageService? coachService,
  }) : _coachService = coachService ?? CoachMessageService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condition = context.watch<ConditionProvider>().score;
    final plan = context.watch<PlanProvider>().todayPlan;
    final disruptions = context.watch<DisruptionProvider>();
    final coachMessage =
        _coachService.getMessage(condition, disruptions.logs);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Papetune', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Chaos-Resilient Dad OS',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          if (plan != null)
            PlanModeIndicator(
              mode: plan.mode,
              conditionScore: condition.value,
            ),
          const SizedBox(height: 12),
          ConditionScoreCard(score: condition),
          const SizedBox(height: 12),
          CoachMessageCard(message: coachMessage),
          const SizedBox(height: 16),
          Text('クイック入力', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('タップでカオスイベントを記録（スコアが減少します）',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          QuickInputBar(onTap: onDisruptionTap),
          if (disruptions.last24hLogs.isNotEmpty) ...[
            const SizedBox(height: 16),
            _RecentDisruptionsSection(
              logs: disruptions.last24hLogs,
              currentScore: condition.value,
              onRemove: onDisruptionRemove,
            ),
          ],
          const SizedBox(height: 16),
          if (plan != null) ...[
            Text('今日のプラン', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            TaskListView(plan: plan),
          ],
        ],
      ),
    );
  }
}

class _RecentDisruptionsSection extends StatelessWidget {
  final List<DisruptionLog> logs;
  final int currentScore;
  final void Function(String id) onRemove;

  const _RecentDisruptionsSection({
    required this.logs,
    required this.currentScore,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final sorted = List.of(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final totalImpact =
        logs.fold<int>(0, (sum, l) => sum + l.type.impactScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('直近24hの記録',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const Spacer(),
            Text('合計 -$totalImpact (残り ${currentScore}pt)',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                )),
          ],
        ),
        const SizedBox(height: 8),
        ...sorted.map((log) => Dismissible(
              key: ValueKey(log.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: theme.colorScheme.error,
                child: Icon(Icons.delete_outline,
                    color: theme.colorScheme.onError),
              ),
              onDismissed: (_) => onRemove(log.id),
              child: Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  dense: true,
                  leading: Icon(log.type.icon,
                      size: 20, color: theme.colorScheme.error),
                  title: Text(log.type.label,
                      style: theme.textTheme.bodyMedium),
                  subtitle: Text(timeFormat.format(log.timestamp),
                      style: theme.textTheme.bodySmall),
                  trailing: Text('-${log.type.impactScore}pt',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.error,
                      )),
                ),
              ),
            )),
      ],
    );
  }
}
