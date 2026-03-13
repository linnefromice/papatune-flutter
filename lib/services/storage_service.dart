import 'dart:convert';

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

  StorageService(this._prefs);

  // Profile
  DadProfile? loadProfile() {
    final json = _prefs.getString(_profileKey);
    if (json == null) return null;
    return DadProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveProfile(DadProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    await _prefs.remove(_profileKey);
  }

  // Disruptions
  List<DisruptionLog> loadDisruptions() {
    final json = _prefs.getString(_disruptionsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => DisruptionLog.fromJson(e as Map<String, dynamic>))
        .toList();
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
    final json = _prefs.getString(_plansKey);
    if (json == null) return {};
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((key, value) =>
        MapEntry(key, DailyPlan.fromJson(value as Map<String, dynamic>)));
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

  List<T> _pruneByDays<T>(
      List<T> items, DateTime Function(T) getDate, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return items.where((item) => getDate(item).isAfter(cutoff)).toList();
  }
}
