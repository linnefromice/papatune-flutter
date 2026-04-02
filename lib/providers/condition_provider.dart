import 'package:flutter/foundation.dart';

import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/disruption_log.dart';
import '../services/condition_calculator.dart';

class ConditionProvider extends ChangeNotifier {
  final ConditionCalculator _calculator;

  ConditionProvider({ConditionCalculator? calculator})
      : _calculator = calculator ?? ConditionCalculator();

  ConditionScore _score = ConditionScore(
    value: 100,
    recommendedMode: PlanMode.planA,
  );

  ConditionScore get score => _score;

  void update(List<DisruptionLog> recentLogs) {
    final newScore = _calculator.calculate(recentLogs);
    if (newScore.value == _score.value &&
        newScore.recommendedMode == _score.recommendedMode) {
      return;
    }
    _score = newScore;
    notifyListeners();
  }
}
