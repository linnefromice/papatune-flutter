import 'package:flutter/material.dart';

/// 自律神経スイッチング用アクション
enum AutonomicAction {
  // 交感神経活性化（覚醒・集中モード）
  coldShower('冷水シャワー (30秒)', Icons.shower, AutonomicMode.sympathetic, 3),
  caffeine('カフェイン摂取', Icons.coffee, AutonomicMode.sympathetic, 2),
  boxBreathing('ボックス呼吸法 (4-4-4-4)', Icons.air, AutonomicMode.sympathetic, 1),
  brightLight('高照度光を浴びる', Icons.light_mode, AutonomicMode.sympathetic, 2),
  coldFaceWash('冷水で顔を洗う', Icons.water_drop, AutonomicMode.sympathetic, 1),
  powerPose('パワーポーズ (2分)', Icons.accessibility_new, AutonomicMode.sympathetic, 1),

  // 副交感神経活性化（リラックス・回復モード）
  warmBath('温浴 (38-40度, 15分)', Icons.bathtub, AutonomicMode.parasympathetic, 3),
  deepBreathing('4-7-8呼吸法', Icons.self_improvement, AutonomicMode.parasympathetic, 2),
  dimLight('照明を落とす', Icons.dark_mode, AutonomicMode.parasympathetic, 1),
  noCaffeine('カフェイン断ち (14時以降)', Icons.no_drinks, AutonomicMode.parasympathetic, 2),
  nsdr('NSDR/ヨガニドラ (10分)', Icons.spa, AutonomicMode.parasympathetic, 3),
  gentleStretch('ゆるストレッチ', Icons.airline_seat_flat, AutonomicMode.parasympathetic, 1);

  const AutonomicAction(this.label, this.icon, this.targetMode, this.effectiveness);
  final String label;
  final IconData icon;
  final AutonomicMode targetMode;

  /// 効果度 (1-3): 高いほど切り替え効果が強い
  final int effectiveness;
}

enum AutonomicMode {
  sympathetic('交感神経（覚醒）'),
  parasympathetic('副交感神経（回復）');

  const AutonomicMode(this.label);
  final String label;
}
