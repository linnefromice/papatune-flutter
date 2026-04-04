import 'package:flutter/material.dart';

import '../../../constants/app_values.dart';
import '../../../enums/plan_mode.dart';

class PlanModeIndicator extends StatelessWidget {
  final PlanMode mode;
  final int conditionScore;
  const PlanModeIndicator({
    super.key,
    required this.mode,
    required this.conditionScore,
  });

  String get _thresholdHint {
    switch (mode) {
      case PlanMode.planA:
        return 'スコア $conditionScore (${AppValues.conditionPlanAThreshold}以上)';
      case PlanMode.planB:
        return 'スコア $conditionScore (${AppValues.conditionPlanBThreshold}~${AppValues.conditionPlanAThreshold - 1})';
      case PlanMode.planC:
        return 'スコア $conditionScore (${AppValues.conditionPlanBThreshold}未満)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: mode.color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: mode.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  mode.label.split(' ').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mode.color,
                    ),
                  ),
                  Text(
                    mode.description,
                    style: TextStyle(
                      color: mode.color.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _thresholdHint,
                    style: TextStyle(
                      fontSize: 11,
                      color: mode.color.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
