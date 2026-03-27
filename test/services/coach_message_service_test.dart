import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/models/condition_score.dart';
import 'package:papetune/models/disruption_log.dart';
import 'package:papetune/services/coach_message_service.dart';

void main() {
  late CoachMessageService service;

  setUp(() {
    service = CoachMessageService();
  });

  DisruptionLog makeLog(DisruptionType type, {Duration? ago}) {
    return DisruptionLog(
      type: type,
      timestamp: DateTime.now().subtract(ago ?? Duration.zero),
    );
  }

  group('CoachMessageService', () {
    group('contextual messages', () {
      test('returns excellent day message when no disruptions and score >= 80',
          () {
        final score =
            ConditionScore(value: 85, recommendedMode: PlanMode.planA);
        final message = service.getMessage(score, []);
        expect(message, contains('好調日'));
      });

      test('returns child sick message when childSick disruption exists', () {
        final score =
            ConditionScore(value: 50, recommendedMode: PlanMode.planB);
        final logs = [makeLog(DisruptionType.childSick)];
        final message = service.getMessage(score, logs);
        expect(message, contains('体調不良'));
      });

      test('returns night waking message when nightWaking disruption exists',
          () {
        final score =
            ConditionScore(value: 60, recommendedMode: PlanMode.planB);
        final logs = [makeLog(DisruptionType.nightWaking)];
        final message = service.getMessage(score, logs);
        expect(message, contains('夜中'));
      });

      test('childSick takes priority over nightWaking', () {
        final score =
            ConditionScore(value: 30, recommendedMode: PlanMode.planC);
        final logs = [
          makeLog(DisruptionType.childSick),
          makeLog(DisruptionType.nightWaking),
        ];
        final message = service.getMessage(score, logs);
        expect(message, contains('体調不良'));
      });

      test('ignores disruptions older than 24 hours for contextual messages',
          () {
        final score =
            ConditionScore(value: 85, recommendedMode: PlanMode.planA);
        final logs = [
          makeLog(DisruptionType.childSick, ago: const Duration(hours: 25)),
        ];
        final message = service.getMessage(score, logs);
        // Should get excellent day message, not childSick message
        expect(message, contains('好調日'));
      });
    });

    group('mode-based messages', () {
      test('returns planA message when no contextual message and planA', () {
        final score =
            ConditionScore(value: 75, recommendedMode: PlanMode.planA);
        // tantrum won't trigger contextual message
        final logs = [makeLog(DisruptionType.tantrum)];
        final message = service.getMessage(score, logs);
        expect(message, isNotEmpty);
      });

      test('returns planB message for planB mode', () {
        final score =
            ConditionScore(value: 50, recommendedMode: PlanMode.planB);
        final logs = [makeLog(DisruptionType.tantrum)];
        final message = service.getMessage(score, logs);
        expect(message, isNotEmpty);
      });

      test('returns planC message for planC mode', () {
        final score =
            ConditionScore(value: 20, recommendedMode: PlanMode.planC);
        final logs = [makeLog(DisruptionType.tantrum)];
        final message = service.getMessage(score, logs);
        expect(message, isNotEmpty);
      });

      test('returns non-empty message for all modes without disruptions', () {
        for (final mode in PlanMode.values) {
          final score = ConditionScore(
            value: mode == PlanMode.planA
                ? 75
                : mode == PlanMode.planB
                    ? 50
                    : 20,
            recommendedMode: mode,
          );
          // score < 80, non-empty logs → no contextual, fall through to mode
          final logs = [makeLog(DisruptionType.other)];
          final message = service.getMessage(score, logs);
          expect(message, isNotEmpty, reason: 'mode $mode should have message');
        }
      });
    });
  });
}
