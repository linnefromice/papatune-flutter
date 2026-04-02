import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_values.dart';
import '../models/dad_profile.dart';
import '../models/daily_plan.dart';
import '../models/disruption_log.dart';

class StorageService {
  final SharedPreferences _prefs;

  static const _profileKey = 'papetune_profile';
  static const _disruptionsKey = 'papetune_disruptions';
  static const _plansKey = 'papetune_daily_plans';
  static const _weekdayTemplateKey = 'papetune_weekday_template';
  static const _weekendTemplateKey = 'papetune_weekend_template';

  StorageService(this._prefs);

  // Profile
  DadProfile? loadProfile() {
    try {
      final json = _prefs.getString(_profileKey);
      if (json == null) return null;
      return DadProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('StorageService: Failed to load profile: $e');
      return null;
    }
  }

  Future<void> saveProfile(DadProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    await _prefs.remove(_profileKey);
  }

  // Disruptions
  List<DisruptionLog> loadDisruptions() {
    try {
      final json = _prefs.getString(_disruptionsKey);
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list
          .map((e) => DisruptionLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StorageService: Failed to load disruptions: $e');
      return [];
    }
  }

  Future<void> saveDisruptions(List<DisruptionLog> logs) async {
    final filtered = _pruneByDays(
      logs,
      (l) => l.timestamp,
      AppValues.maxHistoryDays,
    );
    await _prefs.setString(
        _disruptionsKey, jsonEncode(filtered.map((l) => l.toJson()).toList()));
  }

  // Daily Plans
  Map<String, DailyPlan> loadPlans() {
    try {
      final json = _prefs.getString(_plansKey);
      if (json == null) return {};
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((key, value) =>
          MapEntry(key, DailyPlan.fromJson(value as Map<String, dynamic>)));
    } catch (e) {
      debugPrint('StorageService: Failed to load plans: $e');
      return {};
    }
  }

  Future<void> savePlans(Map<String, DailyPlan> plans) async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: AppValues.maxHistoryDays));
    final filtered = Map<String, DailyPlan>.fromEntries(
      plans.entries.where((e) => e.value.date.isAfter(cutoff)),
    );
    await _prefs.setString(_plansKey,
        jsonEncode(filtered.map((k, v) => MapEntry(k, v.toJson()))));
  }

  // Plan Templates
  List<String>? loadWeekdayTemplate() {
    final json = _prefs.getString(_weekdayTemplateKey);
    if (json == null) return null;
    return (jsonDecode(json) as List).cast<String>();
  }

  List<String>? loadWeekendTemplate() {
    final json = _prefs.getString(_weekendTemplateKey);
    if (json == null) return null;
    return (jsonDecode(json) as List).cast<String>();
  }

  Future<void> saveWeekdayTemplate(List<String> tasks) async {
    await _prefs.setString(_weekdayTemplateKey, jsonEncode(tasks));
  }

  Future<void> saveWeekendTemplate(List<String> tasks) async {
    await _prefs.setString(_weekendTemplateKey, jsonEncode(tasks));
  }

  List<T> _pruneByDays<T>(
      List<T> items, DateTime Function(T) getDate, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return items.where((item) => getDate(item).isAfter(cutoff)).toList();
  }
}
