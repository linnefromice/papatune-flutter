import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/enums/disruption_type.dart';
import 'package:papetune/models/disruption_log.dart';

void main() {
  group('DisruptionLog', () {
    test('generates unique ID', () {
      final a = DisruptionLog(type: DisruptionType.nightWaking);
      final b = DisruptionLog(type: DisruptionType.nightWaking);
      expect(a.id, isNot(b.id));
    });

    test('uses provided ID', () {
      final log = DisruptionLog(id: 'custom-id', type: DisruptionType.childSick);
      expect(log.id, 'custom-id');
    });

    test('defaults timestamp to now', () {
      final before = DateTime.now();
      final log = DisruptionLog(type: DisruptionType.tantrum);
      final after = DateTime.now();
      expect(log.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(log.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('toJson and fromJson roundtrip', () {
      final log = DisruptionLog(
        id: 'test-id',
        type: DisruptionType.overwork,
        timestamp: DateTime(2026, 4, 3, 14, 30),
        note: 'テストメモ',
      );
      final json = log.toJson();
      final restored = DisruptionLog.fromJson(json);
      expect(restored.id, 'test-id');
      expect(restored.type, DisruptionType.overwork);
      expect(restored.timestamp, DateTime(2026, 4, 3, 14, 30));
      expect(restored.note, 'テストメモ');
    });

    test('toJson handles null note', () {
      final log = DisruptionLog(type: DisruptionType.lateBedtime);
      final json = log.toJson();
      expect(json['note'], isNull);
    });
  });
}
