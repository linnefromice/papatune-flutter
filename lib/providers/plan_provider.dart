import 'package:flutter/foundation.dart';

import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/daily_plan.dart';
import '../models/plan_task.dart';
import '../models/plan_template.dart';
import '../services/plan_generator.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';

class PlanProvider extends ChangeNotifier {
  final StorageService _storage;
  final PlanGenerator _generator;
  Map<String, DailyPlan> _plans = {};
  DailyPlan? _todayPlan;
  List<PlanTemplate> _templates = [];
  Map<int, String> _dayAssignment = {};

  PlanProvider(this._storage, {PlanGenerator? generator})
      : _generator = generator ?? PlanGenerator() {
    _plans = _storage.loadPlans();
    _templates = _storage.loadTemplates();
    _dayAssignment = _storage.loadDayAssignment();
  }

  DailyPlan? get todayPlan => _todayPlan;
  Map<String, DailyPlan> get plans => Map.unmodifiable(_plans);
  List<PlanTemplate> get templates => List.unmodifiable(_templates);
  Map<int, String> get dayAssignment => Map.unmodifiable(_dayAssignment);

  PlanTemplate? getTemplateForDay(int weekday) {
    final id = _dayAssignment[weekday];
    if (id == null) return null;
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void generateTodayPlan(DadProfile profile, ConditionScore condition) {
    final today = DateTime.now();
    final key = today.toDateKey();

    if (_plans.containsKey(key) &&
        _plans[key]!.mode == condition.recommendedMode) {
      _todayPlan = _plans[key];
      return;
    }

    // テンプレートからプラン生成
    final template = getTemplateForDay(today.weekday);
    if (template != null && template.tasks.isNotEmpty) {
      _todayPlan = DailyPlan(
        date: today,
        mode: condition.recommendedMode,
        tasks: template.tasks.map((t) => PlanTask(title: t)).toList(),
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

  // Template CRUD

  Future<void> addTemplate(PlanTemplate template) async {
    _templates.add(template);
    await _storage.saveTemplates(_templates);
    notifyListeners();
  }

  Future<void> updateTemplate(PlanTemplate template) async {
    final idx = _templates.indexWhere((t) => t.id == template.id);
    if (idx == -1) return;
    _templates[idx] = template;
    await _storage.saveTemplates(_templates);
    notifyListeners();
  }

  Future<void> deleteTemplate(String templateId) async {
    _templates.removeWhere((t) => t.id == templateId);
    // 削除されたテンプレートの曜日割り当てをクリア
    _dayAssignment.removeWhere((_, v) => v == templateId);
    await _storage.saveTemplates(_templates);
    await _storage.saveDayAssignment(_dayAssignment);
    notifyListeners();
  }

  Future<void> saveDayAssignment(Map<int, String> assignment) async {
    _dayAssignment = Map.of(assignment);
    await _storage.saveDayAssignment(_dayAssignment);
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
