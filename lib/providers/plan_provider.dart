import 'package:flutter/foundation.dart';

import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/daily_plan.dart';
import '../services/plan_generator.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';

class PlanProvider extends ChangeNotifier {
  final StorageService _storage;
  final PlanGenerator _generator = PlanGenerator();
  Map<String, DailyPlan> _plans = {};
  DailyPlan? _todayPlan;

  PlanProvider(this._storage) {
    _plans = _storage.loadPlans();
  }

  DailyPlan? get todayPlan => _todayPlan;
  Map<String, DailyPlan> get plans => Map.unmodifiable(_plans);

  void generateTodayPlan(DadProfile profile, ConditionScore condition) {
    final today = DateTime.now();
    final key = today.toDateKey();

    if (_plans.containsKey(key) &&
        _plans[key]!.mode == condition.recommendedMode) {
      _todayPlan = _plans[key];
      return;
    }

    _todayPlan = _generator.generate(profile, condition.recommendedMode, today);
    _plans[key] = _todayPlan!;
    _storage.savePlans(_plans);
    notifyListeners();
  }

  void toggleTask(String taskId) {
    if (_todayPlan == null) return;
    final idx = _todayPlan!.tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _todayPlan!.tasks[idx].isDone = !_todayPlan!.tasks[idx].isDone;
    _storage.savePlans(_plans);
    notifyListeners();
  }

  List<DailyPlan> plansForLastNDays(int n) {
    final now = DateTime.now();
    final result = <DailyPlan>[];
    for (int i = 0; i < n; i++) {
      final key = now.subtract(Duration(days: i)).toDateKey();
      final plan = _plans[key];
      if (plan != null) {
        result.add(plan);
      }
    }
    return result;
  }
}
