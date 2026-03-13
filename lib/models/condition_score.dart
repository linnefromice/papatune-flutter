import '../enums/plan_mode.dart';

class ConditionScore {
  final int value; // 0-100
  final PlanMode recommendedMode;

  ConditionScore({required this.value, required this.recommendedMode});

  String get label {
    if (value >= 70) return '好調';
    if (value >= 40) return '疲労気味';
    return 'サバイバル';
  }

  String get emoji {
    if (value >= 70) return '💪';
    if (value >= 40) return '😴';
    return '🆘';
  }
}
