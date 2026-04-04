import 'package:flutter/material.dart';

import '../../../constants/app_values.dart';
import '../../../models/condition_score.dart';

class ConditionScoreCard extends StatelessWidget {
  final ConditionScore score;
  const ConditionScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showExplanation(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: score.value / 100,
                          strokeWidth: 6,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            score.recommendedMode.color,
                          ),
                        ),
                        Text(
                          '${score.value}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('コンディション',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(width: 4),
                            Icon(Icons.info_outline,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        Text(
                          '${score.emoji} ${score.label}',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ThresholdBar(value: score.value),
            ],
          ),
        ),
      ),
    );
  }

  void _showExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('コンディションスコアとは',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  '直近24時間のカオスイベント（夜泣き、体調不良など）に基づいて自動計算されます。\n'
                  '100点満点から各イベントの影響度が減算されます。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _ExplanationRow(
                  color: Colors.green,
                  label: 'Plan A: 通常モード',
                  range: '70 ~ 100',
                  description: '通常通りのプランで行動',
                ),
                _ExplanationRow(
                  color: Colors.orange,
                  label: 'Plan B: 睡眠不足モード',
                  range: '40 ~ 69',
                  description: 'タスクを軽めに調整',
                ),
                _ExplanationRow(
                  color: Colors.redAccent,
                  label: 'Plan C: サバイバルモード',
                  range: '0 ~ 39',
                  description: '最低限のタスクのみ',
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '現在のスコア: ${score.value} → ${score.label}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: score.recommendedMode.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExplanationRow extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  final String description;

  const _ExplanationRow({
    required this.color,
    required this.label,
    required this.range,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label ($range)',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdBar extends StatelessWidget {
  final int value;
  const _ThresholdBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 20,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final planAStart = width * AppValues.conditionPlanAThreshold / 100;
              final planBStart = width * AppValues.conditionPlanBThreshold / 100;
              final markerPos =
                  (width * value / 100).clamp(0.0, width);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background segments
                  Row(
                    children: [
                      Container(
                        width: planBStart,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withAlpha(60),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(4)),
                        ),
                      ),
                      Container(
                        width: planAStart - planBStart,
                        height: 8,
                        color: Colors.orange.withAlpha(60),
                      ),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(60),
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Current score marker
                  Positioned(
                    left: markerPos - 4,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const SizedBox(width: 2),
            Text('0', style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
            Expanded(
              flex: AppValues.conditionPlanBThreshold,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('${AppValues.conditionPlanBThreshold}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10)),
              ),
            ),
            Expanded(
              flex: AppValues.conditionPlanAThreshold -
                  AppValues.conditionPlanBThreshold,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('${AppValues.conditionPlanAThreshold}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10)),
              ),
            ),
            Expanded(
              flex: 100 - AppValues.conditionPlanAThreshold,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('100',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
