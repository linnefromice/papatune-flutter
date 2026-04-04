import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/constants/app_values.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/enums/plan_mode.dart';
import 'package:papetune/models/condition_score.dart';
import 'package:papetune/models/disruption_log.dart';
import 'package:papetune/services/coach_message_service.dart';

void main() {
  late CoachMessageService service;

  setUp(() {
    // Seeded Random for deterministic tests
    service = CoachMessageService(random: Random(42));
  });

  ConditionScore makeScore(int value, PlanMode mode) =>
      ConditionScore(value: value, recommendedMode: mode);

  DisruptionLog makeLog(DisruptionType type, {Duration? ago}) => DisruptionLog(
        type: type,
        timestamp: DateTime.now().subtract(ago ?? Duration.zero),
      );

  group('CoachMessageService', () {
    group('contextual messages', () {
      test('returns excellent message when no disruptions and high score', () {
        final score = makeScore(AppValues.excellentScoreThreshold, PlanMode.planA);
        final message = service.getMessage(score, []);
        expect(message, contains('好調日'));
      });

      test('returns childSick message when recent child sickness', () {
        final score = makeScore(30, PlanMode.planC);
        final logs = [makeLog(DisruptionType.childSick)];
        final message = service.getMessage(score, logs);
        expect(message, contains('体調不良'));
      });

      test('returns nightWaking message when recent night waking', () {
        final score = makeScore(60, PlanMode.planB);
        final logs = [makeLog(DisruptionType.nightWaking)];
        final message = service.getMessage(score, logs);
        expect(message, contains('夜中'));
      });

      test('childSick takes priority over nightWaking', () {
        final score = makeScore(30, PlanMode.planC);
        final logs = [
          makeLog(DisruptionType.childSick),
          makeLog(DisruptionType.nightWaking),
        ];
        final message = service.getMessage(score, logs);
        expect(message, contains('体調不良'));
      });

      test('ignores disruptions older than 24h for contextual messages', () {
        final score = makeScore(AppValues.excellentScoreThreshold, PlanMode.planA);
        final logs = [
          makeLog(DisruptionType.childSick, ago: const Duration(hours: 25)),
        ];
        final message = service.getMessage(score, logs);
        // Should get excellent message since the disruption is old
        expect(message, contains('好調日'));
      });

      test('no excellent message when score below threshold', () {
        final score = makeScore(
          AppValues.excellentScoreThreshold - 1,
          PlanMode.planA,
        );
        // No recent disruptions but score not excellent → falls to mode messages
        final message = service.getMessage(score, []);
        expect(message, isNot(contains('好調日')));
      });
    });

    group('mode-based messages', () {
      test('returns planA message for planA mode', () {
        // Score below excellent threshold, no contextual triggers
        final score = makeScore(70, PlanMode.planA);
        final logs = [makeLog(DisruptionType.tantrum)];
        final message = service.getMessage(score, logs);
        // Should be one of planA messages — just check it's not empty
        expect(message, isNotEmpty);
      });

      test('returns planB message for planB mode', () {
        final score = makeScore(50, PlanMode.planB);
        final logs = [makeLog(DisruptionType.tantrum)];
        final message = service.getMessage(score, logs);
        expect(message, isNotEmpty);
      });

      test('returns planC message for planC mode', () {
        final score = makeScore(20, PlanMode.planC);
        final logs = [makeLog(DisruptionType.tantrum)];
        final message = service.getMessage(score, logs);
        expect(message, isNotEmpty);
      });

      test('mode messages are non-deterministic with unseeded random', () {
        final unseeded = CoachMessageService();
        final score = makeScore(70, PlanMode.planA);
        final logs = [makeLog(DisruptionType.tantrum)];
        final messages = <String>{};
        for (var i = 0; i < 50; i++) {
          messages.add(unseeded.getMessage(score, logs));
        }
        expect(messages.length, greaterThan(1));
      });

      test('seeded random produces consistent results', () {
        final a = CoachMessageService(random: Random(0));
        final b = CoachMessageService(random: Random(0));
        final score = makeScore(70, PlanMode.planA);
        final logs = [makeLog(DisruptionType.tantrum)];
        expect(a.getMessage(score, logs), b.getMessage(score, logs));
      });
    });
  });
}
