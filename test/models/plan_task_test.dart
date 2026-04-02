import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/models/plan_task.dart';

void main() {
  group('PlanTask', () {
    test('generates unique ID when not provided', () {
      final t1 = PlanTask(title: 'A');
      final t2 = PlanTask(title: 'B');
      expect(t1.id, isNot(equals(t2.id)));
    });

    test('uses provided ID', () {
      final task = PlanTask(id: 'custom-id', title: 'Test');
      expect(task.id, 'custom-id');
    });

    test('isDone defaults to false', () {
      expect(PlanTask(title: 'Test').isDone, isFalse);
    });

    test('copyWith creates new instance with changed isDone', () {
      final task = PlanTask(title: 'Test', timeSlot: '09:00');
      final toggled = task.copyWith(isDone: true);

      expect(toggled.isDone, isTrue);
      expect(toggled.id, task.id);
      expect(toggled.title, task.title);
      expect(toggled.timeSlot, task.timeSlot);
    });

    test('copyWith preserves all fields when no args', () {
      final task = PlanTask(
        title: 'Test',
        timeSlot: '10:00',
        durationMinutes: 30,
        isOptional: true,
        isDone: true,
      );
      final copy = task.copyWith();
      expect(copy.id, task.id);
      expect(copy.title, task.title);
      expect(copy.timeSlot, task.timeSlot);
      expect(copy.durationMinutes, task.durationMinutes);
      expect(copy.isOptional, task.isOptional);
      expect(copy.isDone, task.isDone);
    });

    group('durationLabel', () {
      test('returns null when no duration', () {
        expect(PlanTask(title: 'T').durationLabel, isNull);
      });

      test('formats minutes only', () {
        expect(PlanTask(title: 'T', durationMinutes: 30).durationLabel, '30m');
      });

      test('formats hours only', () {
        expect(PlanTask(title: 'T', durationMinutes: 120).durationLabel, '2h');
      });

      test('formats hours and minutes', () {
        expect(PlanTask(title: 'T', durationMinutes: 90).durationLabel, '1h30m');
      });
    });

    group('toJson / fromJson', () {
      test('roundtrips correctly', () {
        final task = PlanTask(
          id: 'test-id',
          title: 'テスト',
          timeSlot: '09:00',
          durationMinutes: 60,
          isOptional: true,
          isDone: true,
        );
        final json = task.toJson();
        final restored = PlanTask.fromJson(json);

        expect(restored.id, task.id);
        expect(restored.title, task.title);
        expect(restored.timeSlot, task.timeSlot);
        expect(restored.durationMinutes, task.durationMinutes);
        expect(restored.isOptional, task.isOptional);
        expect(restored.isDone, task.isDone);
      });

      test('fromJson defaults optional fields', () {
        final json = {
          'id': 'x',
          'title': 'test',
          'timeSlot': null,
          'durationMinutes': null,
        };
        final task = PlanTask.fromJson(json);
        expect(task.isOptional, isFalse);
        expect(task.isDone, isFalse);
      });
    });
  });
}
