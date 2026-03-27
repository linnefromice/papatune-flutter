import '../enums/exercise_type.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/disruption_log.dart';
import '../models/exercise_advice.dart';
import '../utils/date_utils.dart';

/// 【観点1】運動の最適化
/// 疲労度・スケジュールに応じた運動種別・強度をロジカルに判断する
class ExerciseOptimizer {
  ExerciseAdvice optimize({
    required DadProfile profile,
    required ConditionScore condition,
    required List<DisruptionLog> recentLogs,
    required DateTime date,
  }) {
    final isSportDay = profile.sportDaysOfWeek.contains(date.weekday);
    final mode = condition.recommendedMode;
    final fatigueLevel = _estimateFatigueLevel(condition, recentLogs);

    // スポーツ日の前日は負荷を下げる（プレパレーション）
    final isSportEve = profile.sportDaysOfWeek.contains(
        date.weekday == 7 ? 1 : date.weekday + 1);

    if (mode == PlanMode.planC) {
      return _survivalMode(isSportDay, mode);
    }

    if (isSportDay) {
      return _sportDayAdvice(fatigueLevel, mode);
    }

    if (isSportEve) {
      return _sportEveAdvice(fatigueLevel, mode);
    }

    return _normalDayAdvice(fatigueLevel, mode);
  }

  int _estimateFatigueLevel(
      ConditionScore condition, List<DisruptionLog> logs) {
    // 直近24hのイベント数と条件スコアから疲労レベルを推定
    final recentCount = logs
        .where((l) => l.timestamp.isWithinLast(const Duration(hours: 24)))
        .length;

    if (condition.value >= 80 && recentCount == 0) return 0; // 回復済み
    if (condition.value >= 60) return 1; // 軽度疲労
    if (condition.value >= 40) return 2; // 中度疲労
    return 3; // 重度疲労
  }

  ExerciseAdvice _survivalMode(bool isSportDay, PlanMode mode) {
    return ExerciseAdvice(
      recommendedType: ExerciseType.none,
      timeSlot: '-',
      durationMinutes: 0,
      reason: 'サバイバルモードでは完全休息を優先。'
          '無理な運動は免疫機能を低下させ、翌日以降のパフォーマンスを更に悪化させます。',
      recoveryTip: '横になれる時間があれば5分でも目を閉じましょう。'
          '光を遮断するだけで副交感神経が優位になります。',
      isSportDay: isSportDay,
      currentMode: mode,
    );
  }

  ExerciseAdvice _sportDayAdvice(int fatigueLevel, PlanMode mode) {
    if (fatigueLevel >= 2) {
      return ExerciseAdvice(
        recommendedType: ExerciseType.sportPractice,
        timeSlot: '17:00',
        durationMinutes: 60,
        reason: '疲労が溜まっていますが、スポーツ日です。'
            '強度を50%に抑え、技術練習メインにしましょう。'
            '身体を動かすことで血流が改善し、気分転換にもなります。',
        warmUpTip: 'いつもより長めにウォーミングアップ (15分)。'
            '股関節・足首のモビリティを重点的に。',
        recoveryTip: '運動後30分以内にプロテイン + 糖質を摂取。'
            '冷水シャワー30秒 → 温水で終えると回復が早まります。',
        isSportDay: true,
        currentMode: mode,
      );
    }

    return ExerciseAdvice(
      recommendedType: fatigueLevel == 0
          ? ExerciseType.sportMatch
          : ExerciseType.sportPractice,
      timeSlot: '17:00',
      durationMinutes: fatigueLevel == 0 ? 90 : 75,
      reason: fatigueLevel == 0
          ? 'コンディション良好！フルパフォーマンスで臨めます。'
          : '軽度の疲労があるため、強度70%を目安に。体の声を聞きながらプレーしましょう。',
      warmUpTip: 'ACL予防を兼ねたダイナミックストレッチ (10分)。'
          'サイドステップ・カリオカ・スキップを必ず入れましょう。',
      recoveryTip: '運動後: ①プロテイン+バナナ ②静的ストレッチ15分 ③水分補給500ml以上',
      isSportDay: true,
      currentMode: mode,
    );
  }

  ExerciseAdvice _sportEveAdvice(int fatigueLevel, PlanMode mode) {
    if (fatigueLevel >= 2) {
      return ExerciseAdvice(
        recommendedType: ExerciseType.lightStretch,
        timeSlot: '21:00',
        durationMinutes: 10,
        reason: '明日のスポーツに備えてリカバリー重視。'
            '疲労がある状態なので、ストレッチで血流を促進し回復を早めます。',
        recoveryTip: 'フォームローラーで大腿四頭筋・ハムストリングスをリリース。',
        isSportDay: false,
        currentMode: mode,
      );
    }

    return ExerciseAdvice(
      recommendedType: ExerciseType.mobilityWork,
      timeSlot: '18:00',
      durationMinutes: 20,
      reason: '明日のフットサルに向けたプレパレーション日。'
          '高強度トレーニングは避け、関節の可動域を広げるモビリティワークを。',
      warmUpTip: '股関節の内外旋・足首の背屈を重点的に。',
      recoveryTip: '早めの入浴 + 十分な睡眠が最大のプレパレーション。',
      isSportDay: false,
      currentMode: mode,
    );
  }

  ExerciseAdvice _normalDayAdvice(int fatigueLevel, PlanMode mode) {
    switch (fatigueLevel) {
      case 0:
        return ExerciseAdvice(
          recommendedType: ExerciseType.bodyWeight,
          timeSlot: '06:30',
          durationMinutes: 25,
          reason: 'コンディション良好。朝の自重トレーニングで代謝を上げ、'
              '1日の認知機能を底上げしましょう。BDNF（脳由来神経栄養因子）が分泌され、'
              '午前中の集中力が向上します。',
          warmUpTip: '体が冷えているので、軽いジョギング or 縄跳び (3分) から開始。',
          recoveryTip: '冷水シャワー30秒でアドレナリンブースト → 朝食へ。',
          isSportDay: false,
          currentMode: mode,
        );
      case 1:
        return ExerciseAdvice(
          recommendedType: ExerciseType.walkWithKids,
          timeSlot: '17:00',
          durationMinutes: 30,
          reason: '軽度の疲労時は、高強度より「動くリカバリー」が効果的。'
              '子どもとの散歩は家族時間とリカバリーを同時に達成できる最高のマルチタスク。',
          recoveryTip: '歩きながら深呼吸 (4秒吸って6秒吐く) で自律神経も整えましょう。',
          isSportDay: false,
          currentMode: mode,
        );
      default:
        return ExerciseAdvice(
          recommendedType: ExerciseType.activeRecovery,
          timeSlot: '21:00',
          durationMinutes: 10,
          reason: '疲労が溜まっています。今日は「戦略的休息日」。'
              'フォームローラーや軽いストレッチで血流を促進し、'
              '翌日以降のトレーニング効果を最大化しましょう。',
          recoveryTip: '入浴後の体が温まった状態でストレッチすると効果的。',
          isSportDay: false,
          currentMode: mode,
        );
    }
  }
}
