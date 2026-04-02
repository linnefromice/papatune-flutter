import 'package:flutter/foundation.dart';

import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/daily_plan.dart';
import '../models/plan_task.dart';
import '../services/plan_generator.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';

class PlanProvider extends ChangeNotifier {
  final StorageService _storage;
  final PlanGenerator _generator = PlanGenerator();
  Map<String, DailyPlan> _plans = {};
  DailyPlan? _todayPlan;
  List<String>? _weekdayTemplate;
  List<String>? _weekendTemplate;

  PlanProvider(this._storage) {
    _plans = _storage.loadPlans();
    _weekdayTemplate = _storage.loadWeekdayTemplate();
    _weekendTemplate = _storage.loadWeekendTemplate();
  }

  DailyPlan? get todayPlan => _todayPlan;
  Map<String, DailyPlan> get plans => Map.unmodifiable(_plans);
  List<String>? get weekdayTemplate => _weekdayTemplate;
  List<String>? get weekendTemplate => _weekendTemplate;

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

  void setTodayPlan(DailyPlan plan) {
    final key = plan.dateKey;
    _todayPlan = plan;
    _plans[key] = plan;
    _storage.savePlans(_plans);
    notifyListeners();
  }

  Future<void> saveWeekdayTemplate(List<PlanTask> tasks) async {
    _weekdayTemplate = tasks.map((t) => t.title).toList();
    await _storage.saveWeekdayTemplate(_weekdayTemplate!);
  }

  Future<void> saveWeekendTemplate(List<PlanTask> tasks) async {
    _weekendTemplate = tasks.map((t) => t.title).toList();
    await _storage.saveWeekendTemplate(_weekendTemplate!);
  }

  void toggleTask(String taskId) {
    if (_todayPlan == null) return;
    final task = _todayPlan!.tasks.firstWhere((t) => t.id == taskId);
    task.isDone = !task.isDone;
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
