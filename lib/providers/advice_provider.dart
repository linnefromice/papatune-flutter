import 'package:flutter/foundation.dart';

import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/daily_advice.dart';
import '../models/disruption_log.dart';
import '../services/advice_generator.dart';

class AdviceProvider extends ChangeNotifier {
  final AdviceGenerator _generator = AdviceGenerator();
  DailyAdvice? _todayAdvice;

  DailyAdvice? get todayAdvice => _todayAdvice;

  void generateAdvice({
    required DadProfile profile,
    required ConditionScore condition,
    required List<DisruptionLog> recentLogs,
  }) {
    _todayAdvice = _generator.generate(
      profile: profile,
      condition: condition,
      recentLogs: recentLogs,
      date: DateTime.now(),
    );
    notifyListeners();
  }
}
