import 'package:flutter/material.dart';

import '../../../../enums/life_role.dart';
import '../../../../models/time_roi_advice.dart';

class TimeRoiSection extends StatelessWidget {
  final TimeRoiAdvice advice;
  const TimeRoiSection({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 戦略カード
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text('時間配分戦略',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(advice.strategy,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ロール別配分
        Text('ロール別時間配分', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...LifeRole.values.map((role) {
          final alloc = advice.allocations[role];
          if (alloc == null) return const SizedBox.shrink();
          return _RoleAllocationCard(allocation: alloc);
        }),
        const SizedBox(height: 16),

        // 高ROI行動
        _ListCard(
          title: '高ROI行動（必ず実行）',
          icon: Icons.trending_up,
          color: Colors.green,
          items: advice.highRoiActions,
        ),
        const SizedBox(height: 12),

        // 低ROI（スキップ推奨）
        _ListCard(
          title: '低ROI（スキップ推奨）',
          icon: Icons.trending_down,
          color: Colors.red,
          items: advice.lowRoiToSkip,
        ),
      ],
    );
  }
}

class _RoleAllocationCard extends StatelessWidget {
  final TimeAllocation allocation;
  const _RoleAllocationCard({required this.allocation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _roleColor(allocation.role);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(allocation.role.icon, color: roleColor),
                const SizedBox(width: 8),
                Text(allocation.role.label,
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  allocation.hoursLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // パーセンテージバー
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: allocation.percentage / 100,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(roleColor),
              ),
            ),
            const SizedBox(height: 4),
            Text('${allocation.percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: roleColor)),
            const SizedBox(height: 8),
            Text(allocation.focus,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }

  Color _roleColor(LifeRole role) {
    switch (role) {
      case LifeRole.engineer:
        return Colors.blue;
      case LifeRole.papa:
        return Colors.green;
      case LifeRole.athlete:
        return Colors.orange;
    }
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _ListCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

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
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        color == Colors.green
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              Text(item, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
