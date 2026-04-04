import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/household_duty.dart';
import 'package:papetune/enums/work_style.dart';
import 'package:papetune/models/child_profile.dart';
import 'package:papetune/models/dad_profile.dart';

void main() {
  group('DadProfile', () {
    test('isRemoteWork is true for remote', () {
      final profile = DadProfile(
        children: [],
        workStyle: WorkStyle.remote,
        duties: {},
        sportDaysOfWeek: [],
      );
      expect(profile.isRemoteWork, isTrue);
    });

    test('isRemoteWork is true for freelance', () {
      final profile = DadProfile(
        children: [],
        workStyle: WorkStyle.freelance,
        duties: {},
        sportDaysOfWeek: [],
      );
      expect(profile.isRemoteWork, isTrue);
    });

    test('isRemoteWork is false for office', () {
      final profile = DadProfile(
        children: [],
        workStyle: WorkStyle.office,
        duties: {},
        sportDaysOfWeek: [],
      );
      expect(profile.isRemoteWork, isFalse);
    });

    test('chaosLevel calculates based on children ages', () {
      final now = DateTime.now();
      final profile = DadProfile(
        children: [
          // 1歳 → +3
          ChildProfile(name: 'A', birthDate: DateTime(now.year - 1, 1, 1)),
          // 4歳 → +2
          ChildProfile(name: 'B', birthDate: DateTime(now.year - 4, 1, 1)),
        ],
        workStyle: WorkStyle.remote,
        duties: {},
        sportDaysOfWeek: [],
      );
      expect(profile.chaosLevel, 5);
    });

    test('chaosLevel is clamped to 10', () {
      final now = DateTime.now();
      final profile = DadProfile(
        children: List.generate(
          5,
          (i) => ChildProfile(
              name: 'C$i', birthDate: DateTime(now.year - 1, 1, 1)),
        ), // 5 toddlers → 15, clamped to 10
        workStyle: WorkStyle.remote,
        duties: {},
        sportDaysOfWeek: [],
      );
      expect(profile.chaosLevel, 10);
    });

    test('sportDaysLabel returns なし for empty', () {
      final profile = DadProfile(
        children: [],
        workStyle: WorkStyle.remote,
        duties: {},
        sportDaysOfWeek: [],
      );
      expect(profile.sportDaysLabel, 'なし');
    });

    test('sportDaysLabel formats weekdays', () {
      final profile = DadProfile(
        children: [],
        workStyle: WorkStyle.remote,
        duties: {},
        sportDaysOfWeek: [1, 3, 5],
      );
      expect(profile.sportDaysLabel, '月, 水, 金');
    });

    test('toJson and fromJson roundtrip', () {
      final profile = DadProfile(
        children: [
          ChildProfile(name: '太郎', birthDate: DateTime(2023, 6, 15)),
        ],
        workStyle: WorkStyle.hybrid,
        duties: {HouseholdDuty.cooking, HouseholdDuty.bathTime},
        sportDaysOfWeek: [2, 4],
        createdAt: DateTime(2026, 1, 1),
      );
      final json = profile.toJson();
      final restored = DadProfile.fromJson(json);
      expect(restored.children.length, 1);
      expect(restored.children[0].name, '太郎');
      expect(restored.workStyle, WorkStyle.hybrid);
      expect(restored.duties, contains(HouseholdDuty.cooking));
      expect(restored.sportDaysOfWeek, [2, 4]);
    });
  });
}
