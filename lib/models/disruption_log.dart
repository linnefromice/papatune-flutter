import 'package:uuid/uuid.dart';

import '../enums/disruption_type.dart';

class DisruptionLog {
  final String id;
  final DisruptionType type;
  final DateTime timestamp;
  final String? note;

  DisruptionLog({
    String? id,
    required this.type,
    DateTime? timestamp,
    this.note,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory DisruptionLog.fromJson(Map<String, dynamic> json) => DisruptionLog(
        id: json['id'] as String,
        type: DisruptionType.values.byName(json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
      );
}
