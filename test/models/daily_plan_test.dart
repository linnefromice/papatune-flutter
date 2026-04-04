import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/models/daily_plan.dart';
import 'package:papetune/models/plan_task.dart';

void main() {
  group('DailyPlan', () {
    test('dateKey formats correctly', () {
      final plan = DailyPlan(
        date: DateTime(2026, 4, 3),
        mode: PlanMode.planA,
        tasks: [],
      );
      expect(plan.dateKey, '2026-04-03');
    });

    test('completedCount counts done tasks', () {
      final plan = DailyPlan(
        date: DateTime(2026, 4, 3),
        mode: PlanMode.planA,
        tasks: [
          PlanTask(title: 'a', isDone: true),
          PlanTask(title: 'b', isDone: false),
          PlanTask(title: 'c', isDone: true),
        ],
      );
      expect(plan.completedCount, 2);
      expect(plan.totalCount, 3);
    });

    test('completedCount is 0 for empty tasks', () {
      final plan = DailyPlan(
        date: DateTime(2026, 4, 3),
        mode: PlanMode.planA,
        tasks: [],
      );
      expect(plan.completedCount, 0);
      expect(plan.totalCount, 0);
    });

    test('copyWithTasks replaces tasks', () {
      final plan = DailyPlan(
        date: DateTime(2026, 4, 3),
        mode: PlanMode.planB,
        tasks: [PlanTask(title: 'old')],
      );
      final newTasks = [PlanTask(title: 'new1'), PlanTask(title: 'new2')];
      final copied = plan.copyWithTasks(newTasks);
      expect(copied.tasks.length, 2);
      expect(copied.mode, PlanMode.planB);
      expect(copied.date, plan.date);
    });

    test('toJson and fromJson roundtrip', () {
      final plan = DailyPlan(
        date: DateTime(2026, 4, 3),
        mode: PlanMode.planC,
        tasks: [
          PlanTask(title: 'タスク1', timeSlot: '08:00', isDone: true),
          PlanTask(title: 'タスク2', isOptional: true),
        ],
      );
      final json = plan.toJson();
      final restored = DailyPlan.fromJson(json);
      expect(restored.dateKey, '2026-04-03');
      expect(restored.mode, PlanMode.planC);
      expect(restored.tasks.length, 2);
      expect(restored.tasks[0].isDone, true);
      expect(restored.tasks[1].isOptional, true);
    });
  });
}
