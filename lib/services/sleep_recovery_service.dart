import '../enums/disruption_type.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/disruption_log.dart';
import '../models/sleep_recovery_advice.dart';
import '../utils/date_utils.dart';

/// 【観点2】睡眠負債からのリカバリー
/// 水・光・仮眠・温度変化等の生理学的ハックによる最速回復アドバイス
class SleepRecoveryService {
  SleepRecoveryAdvice analyze({
    required ConditionScore condition,
    required List<DisruptionLog> recentLogs,
    required PlanMode mode,
    required bool isRemoteWork,
  }) {
    final sleepDisruptions = recentLogs
        .where((l) => l.timestamp.isWithinLast(const Duration(hours: 48)))
        .where((l) =>
            l.type == DisruptionType.nightWaking ||
            l.type == DisruptionType.lateBedtime)
        .toList();

    final debtLevel = _calculateDebtLevel(sleepDisruptions, condition);

    return SleepRecoveryAdvice(
      sleepDebtLevel: debtLevel,
      actions: _buildActions(debtLevel, isRemoteWork),
      summary: _buildSummary(debtLevel),
      napRecommendation: _napRecommendation(debtLevel, isRemoteWork),
      hydrationTip: _hydrationTip(debtLevel),
      lightExposureTip: _lightExposureTip(debtLevel),
      temperatureTip: _temperatureTip(debtLevel),
    );
  }

  int _calculateDebtLevel(
      List<DisruptionLog> sleepDisruptions, ConditionScore condition) {
    final disruptionCount = sleepDisruptions.length;
    if (disruptionCount == 0 && condition.value >= 70) return 0;
    if (disruptionCount <= 1 && condition.value >= 50) return 1;
    if (disruptionCount <= 3) return 2;
    return 3;
  }

  List<RecoveryAction> _buildActions(int debtLevel, bool isRemoteWork) {
    final actions = <RecoveryAction>[];

    // 全レベル共通: 朝の光
    actions.add(RecoveryAction(
      title: '起床後すぐに日光を浴びる',
      timeSlot: '06:30',
      description: '目から光を取り込むことでコルチゾール分泌を促進し、'
          'サーカディアンリズムをリセット。曇りの日でも外に出ましょう（室内光の10倍以上の照度）。',
      category: RecoveryCategory.light,
    ));

    // 全レベル共通: 起床時の水分
    actions.add(RecoveryAction(
      title: '起床後コップ2杯の水',
      timeSlot: '06:30',
      description: '睡眠中に失われた水分 (約500ml) を補給。'
          '常温の水が胃腸への負担が少なくベスト。レモンを入れるとビタミンCも摂取可能。',
      category: RecoveryCategory.hydration,
    ));

    if (debtLevel >= 1) {
      // 軽度以上: 午前の水分補給強化
      actions.add(RecoveryAction(
        title: '午前中に水500ml追加',
        timeSlot: '10:00',
        description: '脱水は疲労感を増幅させます。'
            '睡眠不足時は特に意識的な水分補給が必要。',
        category: RecoveryCategory.hydration,
      ));
    }

    if (debtLevel >= 1 && isRemoteWork) {
      // リモートワーカーは仮眠可能
      actions.add(RecoveryAction(
        title: debtLevel >= 2 ? '昼食後に20分仮眠' : '昼食後に10-15分仮眠',
        timeSlot: '12:30',
        description: debtLevel >= 2
            ? '20分の仮眠でスロー・ウェーブ・スリープに入る直前で起きるのが最適。'
                'アラーム必須。仮眠前にカフェインを摂ると「コーヒーナップ」効果で覚醒がスムーズ。'
            : 'NASA式パワーナップ: 10-15分の仮眠で認知機能が34%向上。'
                '椅子でもOK、暗い環境を作るだけで効果あり。',
        category: RecoveryCategory.nap,
      ));
    } else if (debtLevel >= 1 && !isRemoteWork) {
      actions.add(RecoveryAction(
        title: '昼休みに5分アイマスク',
        timeSlot: '12:30',
        description: 'オフィスでは仮眠が難しくても、5分目を閉じるだけで脳の疲労は軽減されます。'
            'トイレの個室でもOK。',
        category: RecoveryCategory.nap,
      ));
    }

    if (debtLevel >= 2) {
      // 中度以上: 温度変化による回復
      actions.add(RecoveryAction(
        title: '温冷交代浴 (温3分→冷30秒 x 3)',
        timeSlot: '19:30',
        description: '温冷交代浴は末梢血管の収縮と拡張を繰り返し、'
            '血流を大幅に改善。疲労物質の除去と副交感神経の活性化を促進します。'
            '最後は温で終えると入眠しやすくなります。',
        category: RecoveryCategory.temperature,
      ));

      // 早期就寝
      actions.add(RecoveryAction(
        title: '通常より1時間早い就寝',
        timeSlot: '22:00',
        description: '睡眠負債の返済には、週末の寝溜めより毎日30-60分の早寝が効果的。'
            '就寝1時間前からブルーライトをカットし、室温を18-20度に設定。',
        category: RecoveryCategory.temperature,
      ));
    }

    if (debtLevel >= 3) {
      // 重度: 追加のリカバリー
      actions.add(RecoveryAction(
        title: '午後の日光浴 (10分)',
        timeSlot: '15:00',
        description: '午後の眠気が来る時間帯に日光を浴びることで、'
            'メラトニン分泌を適切なタイミングに再調整。夜の入眠が改善されます。',
        category: RecoveryCategory.light,
      ));

      actions.add(RecoveryAction(
        title: '寝室の温度を18度に設定',
        timeSlot: '21:00',
        description: '深部体温が下がることで入眠が促進されます。'
            'エアコンまたは扇風機で寝室を事前に冷やしておきましょう。',
        category: RecoveryCategory.temperature,
      ));
    }

    return actions;
  }

  String _buildSummary(int debtLevel) {
    switch (debtLevel) {
      case 0:
        return '睡眠は十分に取れています。この状態を維持しましょう。'
            '就寝前のルーティンを崩さないことが最重要です。';
      case 1:
        return '軽度の睡眠負債があります。今日は「光」と「水」を意識して、'
            '自然な覚醒をサポートしましょう。無理な運動は避け、早めの就寝を。';
      case 2:
        return '中度の睡眠負債です。パフォーマンスが15-25%低下している可能性があります。'
            '仮眠・温冷交代浴・早寝の3つを実行して2-3日かけて回復しましょう。';
      default:
        return '重度の睡眠負債です。今日は「生存優先」で、可能な限り回復行動を積み重ねてください。'
            '完全回復には3-5日かかりますが、今日のリカバリーアクションが回復の起点になります。';
    }
  }

  String? _napRecommendation(int debtLevel, bool isRemoteWork) {
    if (debtLevel == 0) return null;
    if (isRemoteWork) {
      return debtLevel >= 2
          ? '12:30-13:00に20分仮眠を強く推奨。コーヒーナップ（仮眠直前にカフェイン）が最強の組み合わせ。'
          : '昼食後に10-15分の仮眠を推奨。デスクに突っ伏すだけでもOK。';
    }
    return '通勤中や昼休みに5-10分目を閉じるだけでも効果あり。アイマスクの携帯を推奨。';
  }

  String? _hydrationTip(int debtLevel) {
    if (debtLevel == 0) return null;
    return '睡眠不足時は脱水リスクが高まります。'
        '1日を通じて水2L以上を目標に。カフェイン飲料は水分にカウントしないこと。';
  }

  String? _lightExposureTip(int debtLevel) {
    if (debtLevel == 0) return null;
    return '起床後30分以内に外の光を10分浴びましょう（曇りでもOK）。'
        'サーカディアンリズムのリセットが今日と今夜の睡眠品質を改善します。';
  }

  String? _temperatureTip(int debtLevel) {
    if (debtLevel <= 1) return null;
    return '就寝90分前の入浴（38-40度, 15分）で深部体温を一時的に上げ、'
        'その後の体温低下で自然な入眠を促進。寝室は18-20度が最適。';
  }
}
