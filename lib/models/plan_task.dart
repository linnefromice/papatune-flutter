import 'package:uuid/uuid.dart';

class PlanTask {
  final String id;
  final String title;
  final String? timeSlot;
  final bool isOptional;
  bool isDone;

  PlanTask({
    String? id,
    required this.title,
    this.timeSlot,
    this.isOptional = false,
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeSlot': timeSlot,
        'isOptional': isOptional,
        'isDone': isDone,
      };

  factory PlanTask.fromJson(Map<String, dynamic> json) => PlanTask(
        id: json['id'] as String,
        title: json['title'] as String,
        timeSlot: json['timeSlot'] as String?,
        isOptional: json['isOptional'] as bool? ?? false,
        isDone: json['isDone'] as bool? ?? false,
      );
}
