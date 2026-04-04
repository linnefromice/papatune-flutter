import 'package:flutter/foundation.dart';

import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/daily_plan.dart';
import '../models/plan_task.dart';
import '../services/plan_generator.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';
import 'template_provider.dart';

class PlanProvider extends ChangeNotifier {
  final StorageService _storage;
  final PlanGenerator _generator;
  final TemplateProvider _templateProvider;
  Map<String, DailyPlan> _plans = {};
  DailyPlan? _todayPlan;

  PlanProvider(this._storage, this._templateProvider,
      {PlanGenerator? generator})
      : _generator = generator ?? PlanGenerator() {
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

    final template = _templateProvider.getTemplateForDay(today.weekday);
    if (template != null && template.tasks.isNotEmpty) {
      _todayPlan = DailyPlan(
        date: today,
        mode: condition.recommendedMode,
        tasks: template.tasks
            .map((t) => PlanTask(title: t.title, timeSlot: t.timeSlot))
            .toList(),
      );
    } else {
      _todayPlan =
          _generator.generate(profile, condition.recommendedMode, today);
    }

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

  void toggleTask(String taskId) {
    if (_todayPlan == null) return;
    final idx = _todayPlan!.tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final updatedTasks = List<PlanTask>.from(_todayPlan!.tasks);
    updatedTasks[idx] = updatedTasks[idx].copyWith(
      isDone: !updatedTasks[idx].isDone,
    );
    _todayPlan = _todayPlan!.copyWithTasks(updatedTasks);
    _plans[_todayPlan!.dateKey] = _todayPlan!;
    _storage.savePlans(_plans);
    notifyListeners();
  }

  DailyPlan? getPlanForDate(DateTime date) {
    return _plans[date.toDateKey()];
  }

  bool hasPlanForDate(DateTime date) {
    return _plans.containsKey(date.toDateKey());
  }

  void toggleTaskForDate(DateTime date, String taskId) {
    final key = date.toDateKey();
    final plan = _plans[key];
    if (plan == null) return;
    final idx = plan.tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final updatedTasks = List<PlanTask>.from(plan.tasks);
    updatedTasks[idx] = updatedTasks[idx].copyWith(
      isDone: !updatedTasks[idx].isDone,
    );
    final updated = plan.copyWithTasks(updatedTasks);
    _plans[key] = updated;
    if (_todayPlan != null && _todayPlan!.dateKey == key) {
      _todayPlan = updated;
    }
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
