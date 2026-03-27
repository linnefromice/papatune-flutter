import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/models/disruption_log.dart';
import 'package:papetune/services/condition_calculator.dart';

void main() {
  late ConditionCalculator calculator;

  setUp(() {
    calculator = ConditionCalculator();
  });

  DisruptionLog _log(DisruptionType type, {Duration? ago}) {
    return DisruptionLog(
      type: type,
      timestamp: DateTime.now().subtract(ago ?? Duration.zero),
    );
  }

  group('ConditionCalculator', () {
    test('returns max score (100) with no disruptions', () {
      final result = calculator.calculate([]);
      expect(result.value, 100);
      expect(result.recommendedMode, PlanMode.planA);
    });

    test('subtracts impact score of a single disruption', () {
      final result = calculator.calculate([
        _log(DisruptionType.nightWaking), // impact: 20
      ]);
      expect(result.value, 80);
      expect(result.recommendedMode, PlanMode.planA);
    });

    test('subtracts multiple disruptions', () {
      final result = calculator.calculate([
        _log(DisruptionType.nightWaking), // 20
        _log(DisruptionType.childSick), // 30
      ]);
      expect(result.value, 50);
      expect(result.recommendedMode, PlanMode.planB);
    });

    test('returns planB for score in 40-69 range', () {
      // 100 - 30(childSick) - 10(tantrum) = 60
      final result = calculator.calculate([
        _log(DisruptionType.childSick),
        _log(DisruptionType.tantrum),
      ]);
      expect(result.value, 60);
      expect(result.recommendedMode, PlanMode.planB);
    });

    test('returns planC for score below 40', () {
      // 100 - 30 - 20 - 15 - 15 = 20
      final result = calculator.calculate([
        _log(DisruptionType.childSick), // 30
        _log(DisruptionType.nightWaking), // 20
        _log(DisruptionType.lateBedtime), // 15
        _log(DisruptionType.overwork), // 15
      ]);
      expect(result.value, 20);
      expect(result.recommendedMode, PlanMode.planC);
    });

    test('clamps score to 0 when disruptions exceed 100', () {
      final result = calculator.calculate([
        _log(DisruptionType.childSick), // 30
        _log(DisruptionType.childSick), // 30
        _log(DisruptionType.childSick), // 30
        _log(DisruptionType.nightWaking), // 20
      ]);
      expect(result.value, 0);
      expect(result.recommendedMode, PlanMode.planC);
    });

    test('ignores disruptions older than 24 hours', () {
      final result = calculator.calculate([
        _log(DisruptionType.childSick, ago: const Duration(hours: 25)),
      ]);
      expect(result.value, 100);
      expect(result.recommendedMode, PlanMode.planA);
    });

    test('includes disruptions within 24 hours', () {
      final result = calculator.calculate([
        _log(DisruptionType.nightWaking, ago: const Duration(hours: 23)),
      ]);
      expect(result.value, 80);
      expect(result.recommendedMode, PlanMode.planA);
    });

    test('boundary: score exactly 70 returns planA', () {
      // 100 - 20 - 10 = 70
      final result = calculator.calculate([
        _log(DisruptionType.nightWaking), // 20
        _log(DisruptionType.tantrum), // 10
      ]);
      expect(result.value, 70);
      expect(result.recommendedMode, PlanMode.planA);
    });

    test('boundary: score exactly 40 returns planB', () {
      // 100 - 30 - 20 - 10 = 40
      final result = calculator.calculate([
        _log(DisruptionType.childSick), // 30
        _log(DisruptionType.nightWaking), // 20
        _log(DisruptionType.tantrum), // 10
      ]);
      expect(result.value, 40);
      expect(result.recommendedMode, PlanMode.planB);
    });

    test('boundary: score 39 returns planC', () {
      // 100 - 30 - 20 - 10 - 1 won't work with existing types
      // Use: 100 - 30 - 20 - 15 = 35
      final result = calculator.calculate([
        _log(DisruptionType.childSick), // 30
        _log(DisruptionType.nightWaking), // 20
        _log(DisruptionType.lateBedtime), // 15
      ]);
      expect(result.value, 35);
      expect(result.recommendedMode, PlanMode.planC);
    });

    test('mixes recent and old disruptions correctly', () {
      final result = calculator.calculate([
        _log(DisruptionType.childSick), // 30 — recent, counted
        _log(DisruptionType.childSick, ago: const Duration(hours: 48)), // old, ignored
      ]);
      expect(result.value, 70);
      expect(result.recommendedMode, PlanMode.planA);
    });
  });
}
