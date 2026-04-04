import 'package:uuid/uuid.dart';

class TemplateTask {
  final String title;
  final String? timeSlot;

  const TemplateTask({required this.title, this.timeSlot});

  Map<String, dynamic> toJson() => {
        'title': title,
        if (timeSlot != null) 'timeSlot': timeSlot,
      };

  factory TemplateTask.fromJson(Map<String, dynamic> json) => TemplateTask(
        title: json['title'] as String,
        timeSlot: json['timeSlot'] as String?,
      );
}

class PlanTemplate {
  final String id;
  final String name;
  final List<TemplateTask> tasks;

  PlanTemplate({
    String? id,
    required this.name,
    required this.tasks,
  }) : id = id ?? const Uuid().v4();

  /// Convenience constructor from title strings (no timeSlot).
  PlanTemplate.fromTitles({
    String? id,
    required String name,
    required List<String> titles,
  }) : this(
          id: id,
          name: name,
          tasks: titles.map((t) => TemplateTask(title: t)).toList(),
        );

  PlanTemplate copyWith({
    String? name,
    List<TemplateTask>? tasks,
  }) =>
      PlanTemplate(
        id: id,
        name: name ?? this.name,
        tasks: tasks ?? this.tasks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory PlanTemplate.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as List;
    final tasks = rawTasks.map((t) {
      // Backward compat: old format stored tasks as plain strings
      if (t is String) return TemplateTask(title: t);
      return TemplateTask.fromJson(t as Map<String, dynamic>);
    }).toList();

    return PlanTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      tasks: tasks,
    );
  }
}
