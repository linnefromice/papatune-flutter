import '../enums/plan_mode.dart';
import 'autonomic_advice.dart';
import 'exercise_advice.dart';
import 'meal_advice.dart';
import 'sleep_recovery_advice.dart';
import 'time_roi_advice.dart';

/// 1日分の統合アドバイス
class DailyAdvice {
  final DateTime date;
  final PlanMode mode;
  final ExerciseAdvice exercise;
  final SleepRecoveryAdvice sleepRecovery;
  final MealAdvice meal;
  final AutonomicAdvice autonomic;
  final TimeRoiAdvice timeRoi;

  DailyAdvice({
    required this.date,
    required this.mode,
    required this.exercise,
    required this.sleepRecovery,
    required this.meal,
    required this.autonomic,
    required this.timeRoi,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'mode': mode.name,
        'exercise': exercise.toJson(),
        'sleepRecovery': sleepRecovery.toJson(),
        'meal': meal.toJson(),
        'autonomic': autonomic.toJson(),
        'timeRoi': timeRoi.toJson(),
      };

  factory DailyAdvice.fromJson(Map<String, dynamic> json) => DailyAdvice(
        date: DateTime.parse(json['date'] as String),
        mode: PlanMode.values.byName(json['mode'] as String),
        exercise: ExerciseAdvice.fromJson(
            json['exercise'] as Map<String, dynamic>),
        sleepRecovery: SleepRecoveryAdvice.fromJson(
            json['sleepRecovery'] as Map<String, dynamic>),
        meal: MealAdvice.fromJson(json['meal'] as Map<String, dynamic>),
        autonomic: AutonomicAdvice.fromJson(
            json['autonomic'] as Map<String, dynamic>),
        timeRoi:
            TimeRoiAdvice.fromJson(json['timeRoi'] as Map<String, dynamic>),
      );
}
