import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/household_duty.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/enums/work_style.dart';
import 'package:papetune/models/child_profile.dart';
import 'package:papetune/models/condition_score.dart';
import 'package:papetune/models/dad_profile.dart';
import 'package:papetune/models/daily_plan.dart';
import 'package:papetune/models/plan_task.dart';
import 'package:papetune/models/plan_template.dart';
import 'package:papetune/providers/plan_provider.dart';
import 'package:papetune/providers/template_provider.dart';
import 'package:papetune/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;
  late TemplateProvider templateProvider;
  late PlanProvider provider;
  late DadProfile profile;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    templateProvider = TemplateProvider(storage);
    provider = PlanProvider(storage, templateProvider);
    profile = DadProfile(
      children: [
        ChildProfile(name: 'テスト太郎', birthDate: DateTime(2023, 1, 1)),
      ],
      workStyle: WorkStyle.remote,
      duties: {HouseholdDuty.cooking},
      sportDaysOfWeek: [],
    );
  });

  group('PlanProvider', () {
    test('starts with no today plan', () {
      expect(provider.todayPlan, isNull);
    });

    test('generateTodayPlan creates a plan', () {
      final condition =
          ConditionScore(value: 80, recommendedMode: PlanMode.planA);
      provider.generateTodayPlan(profile, condition);
      expect(provider.todayPlan, isNotNull);
      expect(provider.todayPlan!.mode, PlanMode.planA);
    });

    test('generateTodayPlan notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      final condition =
          ConditionScore(value: 80, recommendedMode: PlanMode.planA);
      provider.generateTodayPlan(profile, condition);
      expect(notified, isTrue);
    });

    test('generateTodayPlan reuses existing plan if mode matches', () {
      final condition =
          ConditionScore(value: 80, recommendedMode: PlanMode.planA);
      provider.generateTodayPlan(profile, condition);
      final firstPlan = provider.todayPlan;

      var notified = false;
      provider.addListener(() => notified = true);
      provider.generateTodayPlan(profile, condition);

      // Should reuse, not regenerate
      expect(provider.todayPlan, same(firstPlan));
      expect(notified, isFalse);
    });

    test('generateTodayPlan regenerates when mode changes', () {
      provider.generateTodayPlan(
        profile,
        ConditionScore(value: 80, recommendedMode: PlanMode.planA),
      );
      final firstPlan = provider.todayPlan;

      provider.generateTodayPlan(
        profile,
        ConditionScore(value: 50, recommendedMode: PlanMode.planB),
      );
      expect(provider.todayPlan!.mode, PlanMode.planB);
      expect(provider.todayPlan, isNot(same(firstPlan)));
    });

    test('setTodayPlan replaces plan and notifies', () {
      final plan = DailyPlan(
        date: DateTime.now(),
        mode: PlanMode.planB,
        tasks: [PlanTask(title: 'テスト')],
      );
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setTodayPlan(plan);

      expect(provider.todayPlan, same(plan));
      expect(notified, isTrue);
    });

    test('toggleTask toggles isDone immutably', () {
      final condition =
          ConditionScore(value: 80, recommendedMode: PlanMode.planA);
      provider.generateTodayPlan(profile, condition);
      final taskId = provider.todayPlan!.tasks.first.id;

      expect(provider.todayPlan!.tasks.first.isDone, isFalse);
      provider.toggleTask(taskId);
      expect(provider.todayPlan!.tasks.first.isDone, isTrue);
      provider.toggleTask(taskId);
      expect(provider.todayPlan!.tasks.first.isDone, isFalse);
    });

    test('toggleTask does nothing for invalid id', () {
      final condition =
          ConditionScore(value: 80, recommendedMode: PlanMode.planA);
      provider.generateTodayPlan(profile, condition);

      var notified = false;
      provider.addListener(() => notified = true);
      provider.toggleTask('nonexistent-id');
      expect(notified, isFalse);
    });

    test('toggleTask does nothing when no plan', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.toggleTask('any-id');
      expect(notified, isFalse);
    });

    test('plansForLastNDays returns correct plans', () {
      final condition =
          ConditionScore(value: 80, recommendedMode: PlanMode.planA);
      provider.generateTodayPlan(profile, condition);

      final plans = provider.plansForLastNDays(7);
      expect(plans.length, 1); // Only today's plan
    });

    test('plans map is unmodifiable', () {
      expect(
        () => (provider.plans as Map)['key'] = null,
        throwsA(anything),
      );
    });

    test('addTemplate persists template via TemplateProvider', () async {
      final template = PlanTemplate.fromTitles(
          name: '平日', titles: ['タスク1', 'タスク2']);
      await templateProvider.addTemplate(template);
      expect(templateProvider.templates.length, 1);
      expect(templateProvider.templates.first.name, '平日');
    });

    test('saveDayAssignment persists assignment via TemplateProvider',
        () async {
      final template =
          PlanTemplate.fromTitles(name: '平日', titles: ['タスク1']);
      await templateProvider.addTemplate(template);
      await templateProvider.saveDayAssignment({1: template.id});
      expect(templateProvider.dayAssignment[1], template.id);
    });
  });
}
