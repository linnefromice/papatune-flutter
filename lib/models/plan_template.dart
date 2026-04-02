import 'package:uuid/uuid.dart';

class PlanTemplate {
  final String id;
  final String name;
  final List<String> tasks;

  PlanTemplate({
    String? id,
    required this.name,
    required this.tasks,
  }) : id = id ?? const Uuid().v4();

  PlanTemplate copyWith({
    String? name,
    List<String>? tasks,
  }) =>
      PlanTemplate(
        id: id,
        name: name ?? this.name,
        tasks: tasks ?? this.tasks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tasks': tasks,
      };

  factory PlanTemplate.fromJson(Map<String, dynamic> json) => PlanTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        tasks: (json['tasks'] as List).cast<String>(),
      );
}
