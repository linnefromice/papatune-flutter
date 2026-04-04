import 'package:flutter/foundation.dart';

import '../models/plan_template.dart';
import '../services/storage_service.dart';

class TemplateProvider extends ChangeNotifier {
  final StorageService _storage;
  List<PlanTemplate> _templates = [];
  Map<int, String> _dayAssignment = {};

  TemplateProvider(this._storage) {
    _templates = _storage.loadTemplates();
    _dayAssignment = _storage.loadDayAssignment();
  }

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
}
