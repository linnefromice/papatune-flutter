import 'package:flutter/foundation.dart';

import '../models/disruption_log.dart';
import '../services/storage_service.dart';

class DisruptionProvider extends ChangeNotifier {
  final StorageService _storage;
  List<DisruptionLog> _logs = [];

  DisruptionProvider(this._storage) {
    _logs = _storage.loadDisruptions();
  }

  List<DisruptionLog> get logs => List.unmodifiable(_logs);

  List<DisruptionLog> get last24hLogs {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _logs.where((l) => l.timestamp.isAfter(cutoff)).toList();
  }

  List<DisruptionLog> logsForDateRange(DateTime start, DateTime end) {
    return _logs
        .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
        .toList();
  }

  Future<void> addDisruption(DisruptionLog log) async {
    _logs.add(log);
    await _storage.saveDisruptions(_logs);
    notifyListeners();
  }

  Future<void> removeDisruption(String id) async {
    _logs.removeWhere((l) => l.id == id);
    await _storage.saveDisruptions(_logs);
    notifyListeners();
  }
}
