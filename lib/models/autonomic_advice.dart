import '../enums/autonomic_action.dart';

/// 自律神経スイッチングアドバイス
class AutonomicAdvice {
  final List<AutonomicScheduleItem> schedule;
  final String caffeineDeadline;
  final String summary;

  AutonomicAdvice({
    required this.schedule,
    required this.caffeineDeadline,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
        'schedule': schedule.map((s) => s.toJson()).toList(),
        'caffeineDeadline': caffeineDeadline,
        'summary': summary,
      };

  factory AutonomicAdvice.fromJson(Map<String, dynamic> json) =>
      AutonomicAdvice(
        schedule: (json['schedule'] as List)
            .map((s) =>
                AutonomicScheduleItem.fromJson(s as Map<String, dynamic>))
            .toList(),
        caffeineDeadline: json['caffeineDeadline'] as String,
        summary: json['summary'] as String,
      );
}

class AutonomicScheduleItem {
  final String timeSlot;
  final AutonomicAction action;
  final String reason;
  final AutonomicMode targetMode;

  AutonomicScheduleItem({
    required this.timeSlot,
    required this.action,
    required this.reason,
    required this.targetMode,
  });

  Map<String, dynamic> toJson() => {
        'timeSlot': timeSlot,
        'action': action.name,
        'reason': reason,
        'targetMode': targetMode.name,
      };

  factory AutonomicScheduleItem.fromJson(Map<String, dynamic> json) =>
      AutonomicScheduleItem(
        timeSlot: json['timeSlot'] as String,
        action: AutonomicAction.values.byName(json['action'] as String),
        reason: json['reason'] as String,
        targetMode: AutonomicMode.values.byName(json['targetMode'] as String),
      );
}
