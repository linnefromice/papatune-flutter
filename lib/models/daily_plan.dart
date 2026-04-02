import '../enums/plan_mode.dart';
import '../utils/date_utils.dart';
import 'plan_task.dart';

class DailyPlan {
  final DateTime date;
  final PlanMode mode;
  final List<PlanTask> tasks;

  DailyPlan({
    required this.date,
    required this.mode,
    required this.tasks,
  });

  String get dateKey => date.toDateKey();

  DailyPlan copyWithTasks(List<PlanTask> tasks) =>
      DailyPlan(date: date, mode: mode, tasks: tasks);

  int get completedCount => tasks.where((t) => t.isDone).length;
  int get totalCount => tasks.length;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'mode': mode.name,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory DailyPlan.fromJson(Map<String, dynamic> json) => DailyPlan(
        date: DateTime.parse(json['date'] as String),
        mode: PlanMode.values.byName(json['mode'] as String),
        tasks: (json['tasks'] as List)
            .map((t) => PlanTask.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}
