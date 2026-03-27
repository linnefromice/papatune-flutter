import 'dart:math';

import '../constants/app_values.dart';
import '../enums/disruption_type.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/disruption_log.dart';
import '../utils/date_utils.dart';

class CoachMessageService {
  final _random = Random();

  String getMessage(
    ConditionScore score,
    List<DisruptionLog> recentLogs, {
    DadProfile? profile,
  }) {
    final contextual = _contextualMessage(recentLogs, score, profile);
    if (contextual != null) return contextual;

    final messages = _messagesForMode[score.recommendedMode]!;
    return messages[_random.nextInt(messages.length)];
  }

  String? _contextualMessage(
    List<DisruptionLog> logs,
    ConditionScore score,
    DadProfile? profile,
  ) {
    final recent = logs
        .where((l) => l.timestamp.isWithinLast(const Duration(hours: 24)))
        .toList();

    if (recent.isEmpty && score.value >= AppValues.excellentScoreThreshold) {
      return '昨日はイレギュラーなしの好調日でした！このコンディションを活かして、少し挑戦的なタスクにも取り組めそうです。'
          '「最適化」タブで今日の運動・食事・時間配分の戦略を確認しましょう。';
    }

    if (recent.any((l) => l.type == DisruptionType.childSick)) {
      return 'お子さんの体調不良、大変ですね。今日は「生き延びること」と「最低限の仕事」のみにフォーカスしましょう。'
          'あなたが倒れたら家族全員が困ります。自分を守ることも育児です。'
          '「最適化」タブで睡眠回復のアドバイスを確認してください。';
    }

    if (recent.any((l) => l.type == DisruptionType.nightWaking)) {
      return '夜中に起こされたんですね、お疲れ様です。'
          '神経系が疲労しているため、無理な運動は逆に週末のスポーツのパフォーマンスを下げます。'
          '「最適化」タブで睡眠負債の回復戦略（光・水・仮眠・温度）を確認しましょう。';
    }

    // スポーツ日の特別メッセージ
    if (profile != null) {
      final isSportDay =
          profile.sportDaysOfWeek.contains(DateTime.now().weekday);
      if (isSportDay && score.value >= 60) {
        return '今日はフットサルの日！コンディションは${score.label}。'
            '「最適化」タブで運動前後の栄養戦略と自律神経の切り替えスケジュールを確認しましょう。';
      }
      if (isSportDay && score.value < 60) {
        return 'フットサルの日ですが、疲労が溜まっています。'
            '強度を落として参加するか、思い切って休むか。'
            '「最適化」タブの運動アドバイスで最適な判断を確認しましょう。';
      }
    }

    return null;
  }

  static const _messagesForMode = {
    PlanMode.planA: [
      '好調です！余裕がある日こそ、自分のための時間を大切に。「最適化」タブで時間ROIを確認しましょう。',
      '今日はフルパフォーマンスで行けそうです。食事の「食べ順」を意識して午後の集中力もキープ。',
      'コンディション良好。平日のうちに週末のスポーツに向けた体づくりを進めましょう。「最適化」タブで運動メニューを確認。',
      '順調な1日になりそうです。朝の冷水シャワーで覚醒を加速させてみませんか？詳細は「最適化」タブで。',
    ],
    PlanMode.planB: [
      'お疲れ気味ですね。今日は「完璧」を目指さず、「まあまあ」で十分です。「最適化」タブで回復戦略を確認。',
      'リモートワーク後の育児対応、素晴らしいタフネスです。昼の仮眠で認知機能を34%回復させましょう。',
      '疲労が溜まっています。ここで無理すると週末に響きます。「最適化」タブの睡眠回復を実践しましょう。',
      '今日は仮眠を優先。15分の昼寝が、3時間の生産性を生みます。食事は血糖値スパイクに要注意。',
    ],
    PlanMode.planC: [
      'サバイバルモード発動。全員が生きて1日を終えれば、それは大勝利です。「最適化」タブのROI戦略を参考に。',
      '今日はすべての運動タスクを削除。食べられるものを食べて、とにかく早寝を目指しましょう。',
      '大変な日ですが、あなたは今まさに「父親としての適応力」を発揮しています。仕事は最重要1タスクだけ。',
      '最低限でOK。こういう日を乗り越えた経験が、あなたの「復元力」を育てます。早寝が最高の投資。',
    ],
  };
}
