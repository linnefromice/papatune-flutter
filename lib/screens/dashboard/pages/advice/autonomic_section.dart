import 'package:flutter/material.dart';

import '../../../../enums/autonomic_action.dart';
import '../../../../models/autonomic_advice.dart';

class AutonomicSection extends StatelessWidget {
  final AutonomicAdvice advice;
  const AutonomicSection({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // サマリーカード
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.swap_horiz,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text('自律神経スイッチング',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(advice.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // カフェイン締め切り
        Card(
          color: Colors.brown.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.coffee, color: Colors.brown),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('カフェイン締め切り',
                          style: theme.textTheme.titleSmall),
                      Text('${advice.caffeineDeadline} 以降はカフェイン断ち',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(advice.caffeineDeadline,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // タイムライン
        Text('1日のスケジュール', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...advice.schedule.map((item) => _ScheduleCard(item: item)),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final AutonomicScheduleItem item;
  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSympathetic = item.targetMode == AutonomicMode.sympathetic;
    final modeColor = isSympathetic ? Colors.deepOrange : Colors.indigo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 時間 + モードインジケーター
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(item.timeSlot,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isSympathetic ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: modeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // アクション詳細
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.action.icon, size: 18, color: modeColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.action.label,
                            style: theme.textTheme.titleSmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
