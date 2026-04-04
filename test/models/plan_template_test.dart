import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/models/plan_template.dart';

void main() {
  group('TemplateTask', () {
    test('toJson and fromJson roundtrip', () {
      final task = TemplateTask(title: '朝食', timeSlot: '07:00');
      final json = task.toJson();
      final restored = TemplateTask.fromJson(json);
      expect(restored.title, '朝食');
      expect(restored.timeSlot, '07:00');
    });

    test('toJson omits null timeSlot', () {
      final task = TemplateTask(title: '仮眠');
      final json = task.toJson();
      expect(json.containsKey('timeSlot'), isFalse);
    });
  });

  group('PlanTemplate', () {
    test('generates unique ID', () {
      final a = PlanTemplate(name: 'A', tasks: []);
      final b = PlanTemplate(name: 'B', tasks: []);
      expect(a.id, isNot(b.id));
    });

    test('fromTitles creates TemplateTasks without timeSlot', () {
      final template =
          PlanTemplate.fromTitles(name: '平日', titles: ['朝食', '昼食']);
      expect(template.tasks.length, 2);
      expect(template.tasks[0].title, '朝食');
      expect(template.tasks[0].timeSlot, isNull);
    });

    test('copyWith preserves ID', () {
      final original = PlanTemplate(name: '元', tasks: []);
      final copied = original.copyWith(name: '新');
      expect(copied.id, original.id);
      expect(copied.name, '新');
    });

    test('toJson and fromJson roundtrip with TemplateTask objects', () {
      final template = PlanTemplate(
        id: 'test-id',
        name: '出社日',
        tasks: [
          TemplateTask(title: '通勤', timeSlot: '08:00'),
          TemplateTask(title: '昼食'),
        ],
      );
      final json = template.toJson();
      final restored = PlanTemplate.fromJson(json);
      expect(restored.id, 'test-id');
      expect(restored.name, '出社日');
      expect(restored.tasks.length, 2);
      expect(restored.tasks[0].timeSlot, '08:00');
      expect(restored.tasks[1].timeSlot, isNull);
    });

    test('fromJson handles legacy string-only tasks', () {
      final json = {
        'id': 'legacy-id',
        'name': '旧形式',
        'tasks': ['朝食', '昼食', '夕食'],
      };
      final template = PlanTemplate.fromJson(json);
      expect(template.tasks.length, 3);
      expect(template.tasks[0].title, '朝食');
      expect(template.tasks[0].timeSlot, isNull);
    });
  });
}
