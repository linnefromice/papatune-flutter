import 'package:flutter/material.dart';

import '../../../../models/meal_advice.dart';

class MealSection extends StatelessWidget {
  final MealAdvice advice;
  const MealSection({super.key, required this.advice});

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
                    Icon(Icons.psychology,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text('今日の食事戦略',
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
        const SizedBox(height: 12),

        // 血糖値Tips
        Card(
          color: Colors.amber.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text('血糖値コントロール',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: Colors.amber.shade800)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(advice.bloodSugarTip,
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 各食事の推奨
        Text('食事プラン', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...advice.meals.map((meal) => _MealCard(meal: meal)),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealRecommendation meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        leading: Icon(meal.timing.icon, color: theme.colorScheme.primary),
        title: Text(meal.timing.label),
        subtitle: Text(meal.timing.defaultTime,
            style: theme.textTheme.labelSmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.recommendation,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // おすすめ食品
                Text('おすすめ',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: Colors.green)),
                const SizedBox(height: 4),
                ...meal.goodFoods.map((food) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('+ ',
                              style: TextStyle(color: Colors.green)),
                          Expanded(
                              child: Text(food,
                                  style: theme.textTheme.bodySmall)),
                        ],
                      ),
                    )),

                // 避けるもの
                if (meal.avoidFoods.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('避けたい',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: Colors.red)),
                  const SizedBox(height: 4),
                  ...meal.avoidFoods.map((food) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('- ',
                                style: TextStyle(color: Colors.red)),
                            Expanded(
                                child: Text(food,
                                    style: theme.textTheme.bodySmall)),
                          ],
                        ),
                      )),
                ],

                // メモ
                if (meal.note != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(meal.note!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
