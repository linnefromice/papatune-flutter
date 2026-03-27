import 'package:flutter/material.dart';

import '../../../../models/sleep_recovery_advice.dart';

class SleepRecoverySection extends StatelessWidget {
  final SleepRecoveryAdvice advice;
  const SleepRecoverySection({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 睡眠負債レベル
        Card(
          color: _debtColor(advice.sleepDebtLevel).withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  _debtIcon(advice.sleepDebtLevel),
                  size: 48,
                  color: _debtColor(advice.sleepDebtLevel),
                ),
                const SizedBox(height: 12),
                Text(
                  advice.debtLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _debtColor(advice.sleepDebtLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  advice.summary,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // リカバリーアクション一覧
        Text('リカバリーアクション', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...advice.actions.map((action) => _ActionCard(action: action)),

        // 追加Tips
        const SizedBox(height: 16),
        if (advice.napRecommendation != null)
          _QuickTip(
            icon: Icons.airline_seat_flat,
            title: '仮眠',
            content: advice.napRecommendation!,
          ),
        if (advice.hydrationTip != null)
          _QuickTip(
            icon: Icons.water_drop,
            title: '水分補給',
            content: advice.hydrationTip!,
          ),
        if (advice.lightExposureTip != null)
          _QuickTip(
            icon: Icons.light_mode,
            title: '光',
            content: advice.lightExposureTip!,
          ),
        if (advice.temperatureTip != null)
          _QuickTip(
            icon: Icons.thermostat,
            title: '温度',
            content: advice.temperatureTip!,
          ),
      ],
    );
  }

  Color _debtColor(int level) {
    switch (level) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.amber;
      case 2:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _debtIcon(int level) {
    switch (level) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.warning_amber;
      case 2:
        return Icons.error_outline;
      default:
        return Icons.dangerous;
    }
  }
}

class _ActionCard extends StatelessWidget {
  final RecoveryAction action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_categoryIcon(action.category),
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(action.title,
                      style: theme.textTheme.titleSmall),
                ),
                Chip(
                  label: Text(action.timeSlot),
                  labelStyle: theme.textTheme.labelSmall,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(action.description, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(RecoveryCategory category) {
    switch (category) {
      case RecoveryCategory.hydration:
        return Icons.water_drop;
      case RecoveryCategory.light:
        return Icons.light_mode;
      case RecoveryCategory.nap:
        return Icons.airline_seat_flat;
      case RecoveryCategory.temperature:
        return Icons.thermostat;
      case RecoveryCategory.nutrition:
        return Icons.restaurant;
    }
  }
}

class _QuickTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _QuickTip(
      {required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 20, color: theme.colorScheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text(content,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
