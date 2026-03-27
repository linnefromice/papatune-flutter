import 'package:flutter/material.dart';

import '../../../../models/exercise_advice.dart';

class ExerciseSection extends StatelessWidget {
  final ExerciseAdvice advice;
  const ExerciseSection({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // メインカード
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(advice.recommendedType.icon,
                        size: 32, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            advice.recommendedType.label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (advice.durationMinutes > 0)
                            Text(
                              '${advice.durationMinutes}分 | ${advice.timeSlot}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  advice.reason,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 疲労負荷メーター
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('疲労負荷', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: advice.recommendedType.fatigueLoad / 10,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          advice.recommendedType.fatigueLoad <= 3
                              ? Colors.green
                              : advice.recommendedType.fatigueLoad <= 6
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${advice.recommendedType.fatigueLoad}/10',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ウォームアップ
        if (advice.warmUpTip != null)
          _TipCard(
            icon: Icons.sports_gymnastics,
            title: 'ウォームアップ',
            content: advice.warmUpTip!,
          ),

        // リカバリー
        if (advice.recoveryTip != null)
          _TipCard(
            icon: Icons.healing,
            title: 'リカバリー',
            content: advice.recoveryTip!,
          ),

        // スポーツ日表示
        if (advice.isSportDay)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              color: Colors.orange.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.sports_soccer, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text('今日はフットサルの日！',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.orange)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _TipCard(
      {required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(title, style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(content, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
