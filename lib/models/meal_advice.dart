import '../enums/meal_timing.dart';

/// 食事戦略アドバイス
class MealAdvice {
  final List<MealRecommendation> meals;
  final String strategy;
  final bool isSportDay;
  final String bloodSugarTip;

  MealAdvice({
    required this.meals,
    required this.strategy,
    required this.isSportDay,
    required this.bloodSugarTip,
  });

  Map<String, dynamic> toJson() => {
        'meals': meals.map((m) => m.toJson()).toList(),
        'strategy': strategy,
        'isSportDay': isSportDay,
        'bloodSugarTip': bloodSugarTip,
      };

  factory MealAdvice.fromJson(Map<String, dynamic> json) => MealAdvice(
        meals: (json['meals'] as List)
            .map((m) => MealRecommendation.fromJson(m as Map<String, dynamic>))
            .toList(),
        strategy: json['strategy'] as String,
        isSportDay: json['isSportDay'] as bool,
        bloodSugarTip: json['bloodSugarTip'] as String,
      );
}

class MealRecommendation {
  final MealTiming timing;
  final String recommendation;
  final List<String> goodFoods;
  final List<String> avoidFoods;
  final String? note;

  MealRecommendation({
    required this.timing,
    required this.recommendation,
    required this.goodFoods,
    this.avoidFoods = const [],
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'timing': timing.name,
        'recommendation': recommendation,
        'goodFoods': goodFoods,
        'avoidFoods': avoidFoods,
        'note': note,
      };

  factory MealRecommendation.fromJson(Map<String, dynamic> json) =>
      MealRecommendation(
        timing: MealTiming.values.byName(json['timing'] as String),
        recommendation: json['recommendation'] as String,
        goodFoods: (json['goodFoods'] as List).cast<String>(),
        avoidFoods: (json['avoidFoods'] as List?)?.cast<String>() ?? [],
        note: json['note'] as String?,
      );
}
