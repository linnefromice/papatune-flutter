import 'dart:math';

import '../constants/app_values.dart';
import '../enums/disruption_type.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/disruption_log.dart';
import '../utils/date_utils.dart';

class CoachMessageService {
  final _random = Random();

  String getMessage(ConditionScore score, List<DisruptionLog> recentLogs) {
    final contextual = _contextualMessage(recentLogs, score);
    if (contextual != null) return contextual;

    final messages = _messagesForMode[score.recommendedMode]!;
    return messages[_random.nextInt(messages.length)];
  }

  String? _contextualMessage(
      List<DisruptionLog> logs, ConditionScore score) {
    final recent = logs
        .where((l) => l.timestamp.isWithinLast(const Duration(hours: 24)))
        .toList();

    if (recent.isEmpty && score.value >= AppValues.excellentScoreThreshold) {
      return '昨日はイレギュラーなしの好調日でした！このコンディションを活かして、少し挑戦的なタスクにも取り組めそうです。';
    }

    if (recent.any((l) => l.type == DisruptionType.childSick)) {
      return 'お子さんの体調不良、大変ですね。今日は「生き延びること」と「最低限の仕事」のみにフォーカスしましょう。あなたが倒れたら家族全員が困ります。自分を守ることも育児です。';
    }

    if (recent.any((l) => l.type == DisruptionType.nightWaking)) {
      return '夜中に起こされたんですね、お疲れ様です。神経系が疲労しているため、無理な運動は逆に週末のスポーツのパフォーマンスを下げます。今日は「戦略的休息日」として、昼休みに10分だけ目を閉じて脳を休めましょう。';
    }

    return null;
  }

  static const _messagesForMode = {
    PlanMode.planA: [
      '好調です！余裕がある日こそ、自分のための時間を大切に。',
      '今日はフルパフォーマンスで行けそうです。でも「頑張りすぎ」にはご注意を。',
      'コンディション良好。平日のうちに週末のスポーツに向けた体づくりを進めましょう。',
      '順調な1日になりそうです。子供と一緒にストレッチするのも良いですね！',
    ],
    PlanMode.planB: [
      'お疲れ気味ですね。今日は「完璧」を目指さず、「まあまあ」で十分です。',
      'リモートワーク後の育児対応、素晴らしいタフネスです。少しペースダウンしましょう。',
      '疲労が溜まっています。ここで無理すると週末に響きます。戦略的に休みましょう。',
      '今日は仮眠を優先。15分の昼寝が、3時間の生産性を生みます。',
    ],
    PlanMode.planC: [
      'サバイバルモード発動。全員が生きて1日を終えれば、それは大勝利です。',
      '今日はすべての運動タスクを削除。炭水化物を多めに摂ってエネルギーを確保しましょう。',
      '大変な日ですが、あなたは今まさに「父親としての適応力」を発揮しています。',
      '最低限でOK。こういう日を乗り越えた経験が、あなたの「復元力」を育てます。',
    ],
  };
}
