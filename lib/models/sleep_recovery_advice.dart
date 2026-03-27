/// 睡眠負債リカバリーアドバイス
class SleepRecoveryAdvice {
  final int sleepDebtLevel; // 0-3: 0=なし, 1=軽度, 2=中度, 3=重度
  final List<RecoveryAction> actions;
  final String summary;
  final String? napRecommendation;
  final String? hydrationTip;
  final String? lightExposureTip;
  final String? temperatureTip;

  SleepRecoveryAdvice({
    required this.sleepDebtLevel,
    required this.actions,
    required this.summary,
    this.napRecommendation,
    this.hydrationTip,
    this.lightExposureTip,
    this.temperatureTip,
  });

  String get debtLabel {
    switch (sleepDebtLevel) {
      case 0:
        return '睡眠負債なし';
      case 1:
        return '軽度の睡眠負債';
      case 2:
        return '中度の睡眠負債';
      default:
        return '重度の睡眠負債';
    }
  }

  Map<String, dynamic> toJson() => {
        'sleepDebtLevel': sleepDebtLevel,
        'actions': actions.map((a) => a.toJson()).toList(),
        'summary': summary,
        'napRecommendation': napRecommendation,
        'hydrationTip': hydrationTip,
        'lightExposureTip': lightExposureTip,
        'temperatureTip': temperatureTip,
      };

  factory SleepRecoveryAdvice.fromJson(Map<String, dynamic> json) =>
      SleepRecoveryAdvice(
        sleepDebtLevel: json['sleepDebtLevel'] as int,
        actions: (json['actions'] as List)
            .map((a) => RecoveryAction.fromJson(a as Map<String, dynamic>))
            .toList(),
        summary: json['summary'] as String,
        napRecommendation: json['napRecommendation'] as String?,
        hydrationTip: json['hydrationTip'] as String?,
        lightExposureTip: json['lightExposureTip'] as String?,
        temperatureTip: json['temperatureTip'] as String?,
      );
}

class RecoveryAction {
  final String title;
  final String timeSlot;
  final String description;
  final RecoveryCategory category;

  RecoveryAction({
    required this.title,
    required this.timeSlot,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'timeSlot': timeSlot,
        'description': description,
        'category': category.name,
      };

  factory RecoveryAction.fromJson(Map<String, dynamic> json) => RecoveryAction(
        title: json['title'] as String,
        timeSlot: json['timeSlot'] as String,
        description: json['description'] as String,
        category:
            RecoveryCategory.values.byName(json['category'] as String),
      );
}

enum RecoveryCategory {
  hydration('水分'),
  light('光'),
  nap('仮眠'),
  temperature('温度'),
  nutrition('栄養');

  const RecoveryCategory(this.label);
  final String label;
}
