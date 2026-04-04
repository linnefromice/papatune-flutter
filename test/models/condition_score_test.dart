import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/models/condition_score.dart';

void main() {
  group('ConditionScore', () {
    test('label returns 好調 for score >= 70', () {
      final score =
          ConditionScore(value: 70, recommendedMode: PlanMode.planA);
      expect(score.label, '好調');
    });

    test('label returns 疲労気味 for score 40-69', () {
      final score =
          ConditionScore(value: 50, recommendedMode: PlanMode.planB);
      expect(score.label, '疲労気味');
    });

    test('label returns サバイバル for score < 40', () {
      final score =
          ConditionScore(value: 20, recommendedMode: PlanMode.planC);
      expect(score.label, 'サバイバル');
    });

    test('emoji returns correct values', () {
      expect(
        ConditionScore(value: 80, recommendedMode: PlanMode.planA).emoji,
        '💪',
      );
      expect(
        ConditionScore(value: 50, recommendedMode: PlanMode.planB).emoji,
        '😴',
      );
      expect(
        ConditionScore(value: 10, recommendedMode: PlanMode.planC).emoji,
        '🆘',
      );
    });

    test('boundary: score 69 is 疲労気味', () {
      final score =
          ConditionScore(value: 69, recommendedMode: PlanMode.planB);
      expect(score.label, '疲労気味');
    });

    test('boundary: score 39 is サバイバル', () {
      final score =
          ConditionScore(value: 39, recommendedMode: PlanMode.planC);
      expect(score.label, 'サバイバル');
    });
  });
}
