import 'package:flutter/material.dart';

enum ExerciseType {
  highIntensity('高強度トレーニング', Icons.fitness_center, 8),
  moderateCardio('中強度有酸素', Icons.directions_run, 5),
  lightStretch('軽ストレッチ', Icons.self_improvement, 2),
  activeRecovery('アクティブリカバリー', Icons.spa, 1),
  sportPractice('フットサル練習', Icons.sports_soccer, 7),
  sportMatch('フットサル試合', Icons.emoji_events, 9),
  bodyWeight('自重トレーニング', Icons.accessibility_new, 5),
  mobilityWork('モビリティワーク', Icons.airline_seat_flat, 2),
  walkWithKids('子どもと散歩', Icons.directions_walk, 3),
  none('運動なし（完全休息）', Icons.hotel, 0);

  const ExerciseType(this.label, this.icon, this.fatigueLoad);
  final String label;
  final IconData icon;

  /// 疲労負荷 (0-10): 高いほど身体への負担が大きい
  final int fatigueLoad;
}
