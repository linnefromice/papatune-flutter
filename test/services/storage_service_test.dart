import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/enums/household_duty.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/enums/work_style.dart';
import 'package:papetune/models/child_profile.dart';
import 'package:papetune/models/dad_profile.dart';
import 'package:papetune/models/daily_plan.dart';
import 'package:papetune/models/disruption_log.dart';
import 'package:papetune/models/plan_task.dart';
import 'package:papetune/services/storage_service.dart';

void main() {
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
  });

  group('StorageService - Profile', () {
    test('returns null when no profile saved', () {
      expect(storage.loadProfile(), isNull);
    });

    test('save and load profile roundtrip', () async {
      final profile = DadProfile(
        children: [
          ChildProfile(name: 'テスト太郎', birthDate: DateTime(2022, 6, 15)),
        ],
        workStyle: WorkStyle.remote,
        duties: {HouseholdDuty.cooking, HouseholdDuty.bathTime},
        sportDaysOfWeek: [1, 5],
        createdAt: DateTime(2026, 1, 1),
      );

      await storage.saveProfile(profile);
      final loaded = storage.loadProfile();

      expect(loaded, isNotNull);
      expect(loaded!.children.length, 1);
      expect(loaded.children.first.name, 'テスト太郎');
      expect(loaded.workStyle, WorkStyle.remote);
      expect(loaded.duties, {HouseholdDuty.cooking, HouseholdDuty.bathTime});
      expect(loaded.sportDaysOfWeek, [1, 5]);
    });

    test('clearProfile removes saved profile', () async {
      final profile = DadProfile(
        children: [
          ChildProfile(name: 'テスト', birthDate: DateTime(2023, 1, 1)),
        ],
        workStyle: WorkStyle.office,
        duties: {},
        sportDaysOfWeek: [],
      );

      await storage.saveProfile(profile);
      expect(storage.loadProfile(), isNotNull);

      await storage.clearProfile();
      expect(storage.loadProfile(), isNull);
    });

    test('returns null for corrupted profile JSON', () async {
      SharedPreferences.setMockInitialValues({
        'papetune_profile': 'not valid json{{{',
      });
      final prefs = await SharedPreferences.getInstance();
      final s = StorageService(prefs);

      expect(s.loadProfile(), isNull);
    });
  });

  group('StorageService - Disruptions', () {
    test('returns empty list when no disruptions saved', () {
      expect(storage.loadDisruptions(), isEmpty);
    });

    test('save and load disruptions roundtrip', () async {
      final logs = [
        DisruptionLog(
          id: 'test-1',
          type: DisruptionType.nightWaking,
          timestamp: DateTime.now(),
          note: 'テストメモ',
        ),
        DisruptionLog(
          id: 'test-2',
          type: DisruptionType.childSick,
          timestamp: DateTime.now(),
        ),
      ];

      await storage.saveDisruptions(logs);
      final loaded = storage.loadDisruptions();

      expect(loaded.length, 2);
      expect(loaded[0].id, 'test-1');
      expect(loaded[0].type, DisruptionType.nightWaking);
      expect(loaded[0].note, 'テストメモ');
      expect(loaded[1].id, 'test-2');
      expect(loaded[1].type, DisruptionType.childSick);
    });

    test('prunes disruptions older than 30 days', () async {
      final logs = [
        DisruptionLog(
          id: 'recent',
          type: DisruptionType.tantrum,
          timestamp: DateTime.now(),
        ),
        DisruptionLog(
          id: 'old',
          type: DisruptionType.tantrum,
          timestamp: DateTime.now().subtract(const Duration(days: 31)),
        ),
      ];

      await storage.saveDisruptions(logs);
      final loaded = storage.loadDisruptions();

      expect(loaded.length, 1);
      expect(loaded.first.id, 'recent');
    });

    test('returns empty list for corrupted disruptions JSON', () async {
      SharedPreferences.setMockInitialValues({
        'papetune_disruptions': '{bad json',
      });
      final prefs = await SharedPreferences.getInstance();
      final s = StorageService(prefs);

      expect(s.loadDisruptions(), isEmpty);
    });
  });

  group('StorageService - Plans', () {
    test('returns empty map when no plans saved', () {
      expect(storage.loadPlans(), isEmpty);
    });

    test('save and load plans roundtrip', () async {
      final plans = {
        '2026-03-28': DailyPlan(
          date: DateTime(2026, 3, 28),
          mode: PlanMode.planA,
          tasks: [
            PlanTask(id: 'task-1', title: '朝のストレッチ', timeSlot: '06:30'),
          ],
        ),
      };

      await storage.savePlans(plans);
      final loaded = storage.loadPlans();

      expect(loaded.length, 1);
      expect(loaded['2026-03-28'], isNotNull);
      expect(loaded['2026-03-28']!.mode, PlanMode.planA);
      expect(loaded['2026-03-28']!.tasks.length, 1);
      expect(loaded['2026-03-28']!.tasks.first.title, '朝のストレッチ');
    });

    test('prunes plans older than 30 days', () async {
      final plans = {
        '2026-03-28': DailyPlan(
          date: DateTime(2026, 3, 28),
          mode: PlanMode.planA,
          tasks: [PlanTask(id: 't1', title: 'Recent')],
        ),
        '2026-01-01': DailyPlan(
          date: DateTime(2026, 1, 1),
          mode: PlanMode.planB,
          tasks: [PlanTask(id: 't2', title: 'Old')],
        ),
      };

      await storage.savePlans(plans);
      final loaded = storage.loadPlans();

      expect(loaded.length, 1);
      expect(loaded.containsKey('2026-03-28'), isTrue);
    });

    test('returns empty map for corrupted plans JSON', () async {
      SharedPreferences.setMockInitialValues({
        'papetune_daily_plans': 'invalid!!!',
      });
      final prefs = await SharedPreferences.getInstance();
      final s = StorageService(prefs);

      expect(s.loadPlans(), isEmpty);
    });
  });
}
