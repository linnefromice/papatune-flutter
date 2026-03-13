import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/disruption_type.dart';
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
  final VoidCallback onRefresh;
  final CoachMessageService _coachService;

  DashboardHomePage({
    super.key,
    required this.onDisruptionTap,
    required this.onRefresh,
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
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Papetune', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Chaos-Resilient Dad OS',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            if (plan != null) PlanModeIndicator(mode: plan.mode),
            const SizedBox(height: 12),
            ConditionScoreCard(score: condition),
            const SizedBox(height: 12),
            CoachMessageCard(message: coachMessage),
            const SizedBox(height: 16),
            Text('クイック入力', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            QuickInputBar(onTap: onDisruptionTap),
            const SizedBox(height: 16),
            if (plan != null) ...[
              Text('今日のプラン', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              TaskListView(plan: plan),
            ],
          ],
        ),
      ),
    );
  }
}
