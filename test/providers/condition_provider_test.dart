import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/models/disruption_log.dart';
import 'package:papetune/providers/condition_provider.dart';

void main() {
  late ConditionProvider provider;

  setUp(() {
    provider = ConditionProvider();
  });

  DisruptionLog makeLog(DisruptionType type, {Duration? ago}) => DisruptionLog(
        type: type,
        timestamp: DateTime.now().subtract(ago ?? Duration.zero),
      );

  group('ConditionProvider', () {
    test('initial score is 100 with planA', () {
      expect(provider.score.value, 100);
      expect(provider.score.recommendedMode, PlanMode.planA);
    });

    test('update calculates new score from disruptions', () {
      provider.update([makeLog(DisruptionType.nightWaking)]); // -20
      expect(provider.score.value, 80);
      expect(provider.score.recommendedMode, PlanMode.planA);
    });

    test('update notifies listeners on change', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.update([makeLog(DisruptionType.childSick)]); // -30
      expect(notified, isTrue);
    });

    test('update does not notify when score unchanged', () {
      provider.update([makeLog(DisruptionType.nightWaking)]);
      var notified = false;
      provider.addListener(() => notified = true);
      // Same disruptions → same score
      provider.update([makeLog(DisruptionType.nightWaking)]);
      expect(notified, isFalse);
    });

    test('update reflects multiple disruptions', () {
      provider.update([
        makeLog(DisruptionType.childSick), // -30
        makeLog(DisruptionType.nightWaking), // -20
        makeLog(DisruptionType.lateBedtime), // -15
      ]);
      expect(provider.score.value, 35);
      expect(provider.score.recommendedMode, PlanMode.planC);
    });

    test('score recovers when disruptions are removed', () {
      provider.update([makeLog(DisruptionType.childSick)]); // 70
      expect(provider.score.value, 70);

      provider.update([]); // back to 100
      expect(provider.score.value, 100);
    });
  });
}
