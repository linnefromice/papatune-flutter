import '../enums/life_role.dart';
import '../enums/plan_mode.dart';

/// タイムパフォーマンス（ROI）最適化アドバイス
class TimeRoiAdvice {
  final Map<LifeRole, TimeAllocation> allocations;
  final PlanMode currentMode;
  final String strategy;
  final List<String> highRoiActions;
  final List<String> lowRoiToSkip;

  TimeRoiAdvice({
    required this.allocations,
    required this.currentMode,
    required this.strategy,
    required this.highRoiActions,
    required this.lowRoiToSkip,
  });

  int get totalMinutes =>
      allocations.values.fold(0, (sum, a) => sum + a.minutes);

  Map<String, dynamic> toJson() => {
        'allocations': allocations
            .map((k, v) => MapEntry(k.name, v.toJson())),
        'currentMode': currentMode.name,
        'strategy': strategy,
        'highRoiActions': highRoiActions,
        'lowRoiToSkip': lowRoiToSkip,
      };

  factory TimeRoiAdvice.fromJson(Map<String, dynamic> json) => TimeRoiAdvice(
        allocations:
            (json['allocations'] as Map<String, dynamic>).map((k, v) =>
                MapEntry(
                  LifeRole.values.byName(k),
                  TimeAllocation.fromJson(v as Map<String, dynamic>),
                )),
        currentMode: PlanMode.values.byName(json['currentMode'] as String),
        strategy: json['strategy'] as String,
        highRoiActions: (json['highRoiActions'] as List).cast<String>(),
        lowRoiToSkip: (json['lowRoiToSkip'] as List).cast<String>(),
      );
}

class TimeAllocation {
  final LifeRole role;
  final int minutes;
  final double percentage;
  final String focus;

  TimeAllocation({
    required this.role,
    required this.minutes,
    required this.percentage,
    required this.focus,
  });

  String get hoursLabel {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m分';
    if (m == 0) return '$h時間';
    return '$h時間$m分';
  }

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'minutes': minutes,
        'percentage': percentage,
        'focus': focus,
      };

  factory TimeAllocation.fromJson(Map<String, dynamic> json) =>
      TimeAllocation(
        role: LifeRole.values.byName(json['role'] as String),
        minutes: json['minutes'] as int,
        percentage: (json['percentage'] as num).toDouble(),
        focus: json['focus'] as String,
      );
}
