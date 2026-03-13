import '../constants/app_values.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/disruption_log.dart';
import '../utils/date_utils.dart';

class ConditionCalculator {
  ConditionScore calculate(List<DisruptionLog> recentLogs) {
    final recentDisruptions = recentLogs
        .where((l) => l.timestamp.isWithinLast(const Duration(hours: 24)));

    int score = AppValues.conditionMax;
    for (final log in recentDisruptions) {
      score -= log.type.impactScore;
    }
    score = score.clamp(0, AppValues.conditionMax);

    final PlanMode mode;
    if (score >= AppValues.conditionPlanAThreshold) {
      mode = PlanMode.planA;
    } else if (score >= AppValues.conditionPlanBThreshold) {
      mode = PlanMode.planB;
    } else {
      mode = PlanMode.planC;
    }

    return ConditionScore(value: score, recommendedMode: mode);
  }
}
