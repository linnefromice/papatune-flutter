import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/household_duty.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/enums/work_style.dart';
import 'package:papetune/models/child_profile.dart';
import 'package:papetune/models/dad_profile.dart';
import 'package:papetune/services/plan_generator.dart';

void main() {
  late PlanGenerator generator;
  late DadProfile remoteProfile;
  late DadProfile officeProfile;

  setUp(() {
    generator = PlanGenerator();
    remoteProfile = DadProfile(
      children: [
        ChildProfile(name: 'テスト太郎', birthDate: DateTime(2022, 1, 1)),
      ],
      workStyle: WorkStyle.remote,
      duties: {HouseholdDuty.cooking, HouseholdDuty.bathTime},
      sportDaysOfWeek: [1, 3], // Monday, Wednesday
    );
    officeProfile = DadProfile(
      children: [
        ChildProfile(name: 'テスト太郎', birthDate: DateTime(2022, 1, 1)),
      ],
      workStyle: WorkStyle.office,
      duties: {HouseholdDuty.cooking},
      sportDaysOfWeek: [],
    );
  });

  group('PlanGenerator', () {
    group('planA', () {
      test('generates plan with correct mode and date', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planA, date);
        expect(plan.mode, PlanMode.planA);
        expect(plan.date, date);
      });

      test('includes morning routine tasks', () {
        final date = DateTime(2026, 3, 28); // Saturday — not a sport day
        final plan = generator.generate(remoteProfile, PlanMode.planA, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('朝のストレッチ (10分)'));
        expect(titles, contains('朝食 & 子供の準備'));
        expect(titles, contains('就寝'));
      });

      test('includes remote work tasks for remote workers', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planA, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('集中ワークタイム'));
      });

      test('includes office work tasks for office workers', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(officeProfile, PlanMode.planA, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('通勤 & 仕事'));
      });

      test('includes sport tasks on sport day', () {
        // Monday = weekday 1, which is in remoteProfile.sportDaysOfWeek
        final monday = DateTime(2026, 3, 30); // Monday
        final plan = generator.generate(remoteProfile, PlanMode.planA, monday);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('スポーツ'));
      });

      test('includes duty tasks', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planA, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('夕食の準備'));
        expect(titles, contains('お風呂タイム'));
      });

      test('tasks are sorted by timeSlot', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planA, date);
        final timeSlots = plan.tasks
            .map((t) => t.timeSlot ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        expect(timeSlots, equals(List.from(timeSlots)..sort()));
      });
    });

    group('planB', () {
      test('generates planB with reduced intensity', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planB, date);
        expect(plan.mode, PlanMode.planB);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('軽いストレッチ (5分)'));
        expect(titles, contains('早めの就寝'));
      });

      test('includes reduced work tasks for remote', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planB, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('ワークタイム（ペースダウン可）'));
        expect(titles, contains('午後ワーク（必須タスクのみ）'));
      });

      test('sport task is optional on sport day in planB', () {
        final monday = DateTime(2026, 3, 30);
        final plan = generator.generate(remoteProfile, PlanMode.planB, monday);
        final sportTask = plan.tasks.firstWhere(
          (t) => t.title.contains('スポーツ'),
        );
        expect(sportTask.isOptional, isTrue);
      });
    });

    group('planC', () {
      test('generates minimal survival plan', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planC, date);
        expect(plan.mode, PlanMode.planC);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('起きる → 最低限の準備'));
        expect(titles, contains('子供のケア（最優先）'));
        expect(titles, contains('全員早めに就寝'));
      });

      test('includes minimal work for remote workers', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planC, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('最低限の仕事のみ'));
      });

      test('excludes work tasks for office workers', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(officeProfile, PlanMode.planC, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles.any((t) => t.contains('仕事')), isFalse);
      });

      test('has no sport tasks regardless of sport day', () {
        final monday = DateTime(2026, 3, 30);
        final plan = generator.generate(remoteProfile, PlanMode.planC, monday);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles.any((t) => t.contains('スポーツ')), isFalse);
      });

      test('includes cooking duty as simple meal', () {
        final date = DateTime(2026, 3, 28);
        final plan = generator.generate(remoteProfile, PlanMode.planC, date);
        final titles = plan.tasks.map((t) => t.title).toList();
        expect(titles, contains('食事は簡単なもので OK'));
      });
    });

    group('edge cases', () {
      test('generates plan with no duties', () {
        final profile = DadProfile(
          children: [
            ChildProfile(name: 'テスト', birthDate: DateTime(2023, 6, 1)),
          ],
          workStyle: WorkStyle.remote,
          duties: {},
          sportDaysOfWeek: [],
        );
        final plan = generator.generate(profile, PlanMode.planA, DateTime(2026, 3, 28));
        expect(plan.tasks, isNotEmpty);
        // Should not contain any duty tasks
        expect(plan.tasks.any((t) => t.title == '夕食の準備'), isFalse);
      });

      test('all tasks have unique IDs', () {
        final plan = generator.generate(
          remoteProfile, PlanMode.planA, DateTime(2026, 3, 28));
        final ids = plan.tasks.map((t) => t.id).toSet();
        expect(ids.length, plan.tasks.length);
      });

      test('all tasks start with isDone = false', () {
        final plan = generator.generate(
          remoteProfile, PlanMode.planA, DateTime(2026, 3, 28));
        expect(plan.tasks.every((t) => !t.isDone), isTrue);
      });
    });
  });
}
