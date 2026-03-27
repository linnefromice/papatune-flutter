import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/daily_advice.dart';
import '../models/disruption_log.dart';
import 'autonomic_switch_service.dart';
import 'exercise_optimizer.dart';
import 'meal_strategy_service.dart';
import 'sleep_recovery_service.dart';
import 'time_roi_service.dart';

/// 5つの観点を統合したアドバイス生成サービス
class AdviceGenerator {
  final ExerciseOptimizer _exerciseOptimizer = ExerciseOptimizer();
  final SleepRecoveryService _sleepRecoveryService = SleepRecoveryService();
  final MealStrategyService _mealStrategyService = MealStrategyService();
  final AutonomicSwitchService _autonomicSwitchService =
      AutonomicSwitchService();
  final TimeRoiService _timeRoiService = TimeRoiService();

  DailyAdvice generate({
    required DadProfile profile,
    required ConditionScore condition,
    required List<DisruptionLog> recentLogs,
    required DateTime date,
  }) {
    final mode = condition.recommendedMode;
    final isSportDay = profile.sportDaysOfWeek.contains(date.weekday);

    final exercise = _exerciseOptimizer.optimize(
      profile: profile,
      condition: condition,
      recentLogs: recentLogs,
      date: date,
    );

    final sleepRecovery = _sleepRecoveryService.analyze(
      condition: condition,
      recentLogs: recentLogs,
      mode: mode,
      isRemoteWork: profile.isRemoteWork,
    );

    final meal = _mealStrategyService.generate(
      condition: condition,
      mode: mode,
      isSportDay: isSportDay,
      isRemoteWork: profile.isRemoteWork,
    );

    final autonomic = _autonomicSwitchService.generate(
      profile: profile,
      condition: condition,
      mode: mode,
      date: date,
    );

    final timeRoi = _timeRoiService.generate(
      profile: profile,
      condition: condition,
      mode: mode,
      date: date,
    );

    return DailyAdvice(
      date: date,
      mode: mode,
      exercise: exercise,
      sleepRecovery: sleepRecovery,
      meal: meal,
      autonomic: autonomic,
      timeRoi: timeRoi,
    );
  }
}
