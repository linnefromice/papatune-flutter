import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/models/child_profile.dart';

void main() {
  group('ChildProfile', () {
    test('ageInYears calculates correctly for past birthday this year', () {
      final now = DateTime.now();
      // Birthday already passed this year
      final child = ChildProfile(
        name: 'テスト',
        birthDate: DateTime(now.year - 3, 1, 1),
      );
      expect(child.ageInYears, greaterThanOrEqualTo(3));
    });

    test('ageInYears handles birthday not yet passed', () {
      final now = DateTime.now();
      // Birthday in future this year (Dec 31 if now is not Dec 31)
      final child = ChildProfile(
        name: 'テスト',
        birthDate: DateTime(now.year - 2, 12, 31),
      );
      // Should be 1 or 2 depending on whether Dec 31 has passed
      expect(child.ageInYears, anyOf(1, 2));
    });

    test('ageLabel formats correctly', () {
      final now = DateTime.now();
      final child = ChildProfile(
        name: 'テスト',
        birthDate: DateTime(now.year - 5, 1, 1),
      );
      expect(child.ageLabel, contains('歳'));
    });

    test('toJson and fromJson roundtrip', () {
      final child = ChildProfile(
        name: '太郎',
        birthDate: DateTime(2022, 6, 15),
      );
      final json = child.toJson();
      final restored = ChildProfile.fromJson(json);
      expect(restored.name, '太郎');
      expect(restored.birthDate, DateTime(2022, 6, 15));
    });
  });
}
