import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/models/disruption_log.dart';
import 'package:papetune/providers/disruption_provider.dart';
import 'package:papetune/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;
  late DisruptionProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    provider = DisruptionProvider(storage);
  });

  group('DisruptionProvider', () {
    test('starts with empty logs', () {
      expect(provider.logs, isEmpty);
    });

    test('loads existing disruptions from storage', () async {
      final log = DisruptionLog(
        id: 'test-1',
        type: DisruptionType.nightWaking,
        timestamp: DateTime.now(),
      );
      SharedPreferences.setMockInitialValues({
        'papetune_disruptions': jsonEncode([log.toJson()]),
      });
      final prefs = await SharedPreferences.getInstance();
      final s = StorageService(prefs);
      final p = DisruptionProvider(s);
      expect(p.logs.length, 1);
      expect(p.logs.first.id, 'test-1');
    });

    test('addDisruption adds to list and notifies', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      final log = DisruptionLog(type: DisruptionType.nightWaking);
      await provider.addDisruption(log);

      expect(provider.logs.length, 1);
      expect(notified, isTrue);
    });

    test('removeDisruption removes by ID and notifies', () async {
      final log = DisruptionLog(type: DisruptionType.childSick);
      await provider.addDisruption(log);
      expect(provider.logs.length, 1);

      var notified = false;
      provider.addListener(() => notified = true);
      await provider.removeDisruption(log.id);

      expect(provider.logs, isEmpty);
      expect(notified, isTrue);
    });

    test('last24hLogs filters by timestamp', () async {
      final recentLog = DisruptionLog(
        type: DisruptionType.nightWaking,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      );
      final oldLog = DisruptionLog(
        type: DisruptionType.childSick,
        timestamp: DateTime.now().subtract(const Duration(hours: 25)),
      );
      await provider.addDisruption(recentLog);
      await provider.addDisruption(oldLog);

      expect(provider.logs.length, 2);
      expect(provider.last24hLogs.length, 1);
      expect(provider.last24hLogs.first.id, recentLog.id);
    });

    test('logsForDateRange returns correct range', () async {
      final log1 = DisruptionLog(
        type: DisruptionType.nightWaking,
        timestamp: DateTime(2026, 3, 15, 10, 0),
      );
      final log2 = DisruptionLog(
        type: DisruptionType.tantrum,
        timestamp: DateTime(2026, 3, 16, 10, 0),
      );
      final log3 = DisruptionLog(
        type: DisruptionType.childSick,
        timestamp: DateTime(2026, 3, 17, 10, 0),
      );
      await provider.addDisruption(log1);
      await provider.addDisruption(log2);
      await provider.addDisruption(log3);

      final range = provider.logsForDateRange(
        DateTime(2026, 3, 15),
        DateTime(2026, 3, 17),
      );
      expect(range.length, 2); // log1 and log2 (exclusive end)
    });

    test('logs list is unmodifiable', () {
      expect(() => provider.logs.add(DisruptionLog(type: DisruptionType.other)),
          throwsA(isA<UnsupportedError>()));
    });
  });
}
