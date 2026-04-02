import 'package:uuid/uuid.dart';

class PlanTask {
  final String id;
  final String title;
  final String? timeSlot;
  final int? durationMinutes;
  final bool isOptional;
  final bool isDone;

  PlanTask({
    String? id,
    required this.title,
    this.timeSlot,
    this.durationMinutes,
    this.isOptional = false,
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();

  PlanTask copyWith({bool? isDone}) => PlanTask(
        id: id,
        title: title,
        timeSlot: timeSlot,
        durationMinutes: durationMinutes,
        isOptional: isOptional,
        isDone: isDone ?? this.isDone,
      );

  String? get durationLabel {
    if (durationMinutes == null) return null;
    final h = durationMinutes! ~/ 60;
    final m = durationMinutes! % 60;
    if (h > 0 && m > 0) return '${h}h${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeSlot': timeSlot,
        'durationMinutes': durationMinutes,
        'isOptional': isOptional,
        'isDone': isDone,
      };

  factory PlanTask.fromJson(Map<String, dynamic> json) => PlanTask(
        id: json['id'] as String,
        title: json['title'] as String,
        timeSlot: json['timeSlot'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        isOptional: json['isOptional'] as bool? ?? false,
        isDone: json['isDone'] as bool? ?? false,
      );
}
