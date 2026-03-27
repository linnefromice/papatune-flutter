import '../enums/exercise_type.dart';
import '../enums/plan_mode.dart';

/// 運動最適化アドバイス
class ExerciseAdvice {
  final ExerciseType recommendedType;
  final String timeSlot;
  final int durationMinutes;
  final String reason;
  final String? warmUpTip;
  final String? recoveryTip;
  final bool isSportDay;
  final PlanMode currentMode;

  ExerciseAdvice({
    required this.recommendedType,
    required this.timeSlot,
    required this.durationMinutes,
    required this.reason,
    this.warmUpTip,
    this.recoveryTip,
    required this.isSportDay,
    required this.currentMode,
  });

  String get summary =>
      '${recommendedType.label} ($durationMinutes分) @$timeSlot';

  Map<String, dynamic> toJson() => {
        'recommendedType': recommendedType.name,
        'timeSlot': timeSlot,
        'durationMinutes': durationMinutes,
        'reason': reason,
        'warmUpTip': warmUpTip,
        'recoveryTip': recoveryTip,
        'isSportDay': isSportDay,
        'currentMode': currentMode.name,
      };

  factory ExerciseAdvice.fromJson(Map<String, dynamic> json) => ExerciseAdvice(
        recommendedType:
            ExerciseType.values.byName(json['recommendedType'] as String),
        timeSlot: json['timeSlot'] as String,
        durationMinutes: json['durationMinutes'] as int,
        reason: json['reason'] as String,
        warmUpTip: json['warmUpTip'] as String?,
        recoveryTip: json['recoveryTip'] as String?,
        isSportDay: json['isSportDay'] as bool,
        currentMode: PlanMode.values.byName(json['currentMode'] as String),
      );
}
