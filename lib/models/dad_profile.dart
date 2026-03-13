import '../constants/app_values.dart';
import '../enums/household_duty.dart';
import '../enums/work_style.dart';
import 'child_profile.dart';

class DadProfile {
  final List<ChildProfile> children;
  final WorkStyle workStyle;
  final Set<HouseholdDuty> duties;
  final List<int> sportDaysOfWeek; // 1=Mon, 7=Sun
  final DateTime createdAt;

  DadProfile({
    required this.children,
    required this.workStyle,
    required this.duties,
    required this.sportDaysOfWeek,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRemoteWork =>
      workStyle == WorkStyle.remote || workStyle == WorkStyle.freelance;

  int get chaosLevel {
    int level = 0;
    for (final child in children) {
      if (child.ageInYears <= 2) {
        level += 3;
      } else if (child.ageInYears <= 5) {
        level += 2;
      } else {
        level += 1;
      }
    }
    return level.clamp(0, 10);
  }

  String get sportDaysLabel {
    if (sportDaysOfWeek.isEmpty) return 'なし';
    return sportDaysOfWeek
        .map((d) => AppValues.weekdayLabels[d] ?? '')
        .join(', ');
  }

  Map<String, dynamic> toJson() => {
        'children': children.map((c) => c.toJson()).toList(),
        'workStyle': workStyle.name,
        'duties': duties.map((d) => d.name).toList(),
        'sportDaysOfWeek': sportDaysOfWeek,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DadProfile.fromJson(Map<String, dynamic> json) => DadProfile(
        children: (json['children'] as List)
            .map((c) => ChildProfile.fromJson(c as Map<String, dynamic>))
            .toList(),
        workStyle: WorkStyle.values.byName(json['workStyle'] as String),
        duties: (json['duties'] as List)
            .map((d) => HouseholdDuty.values.byName(d as String))
            .toSet(),
        sportDaysOfWeek: (json['sportDaysOfWeek'] as List).cast<int>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
