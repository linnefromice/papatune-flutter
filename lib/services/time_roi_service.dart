import '../enums/life_role.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/dad_profile.dart';
import '../models/time_roi_advice.dart';

/// 【観点5】究極のタイムパフォーマンス(ROI)
/// 仕事・家族・趣味のリソース配分最適化
class TimeRoiService {
  /// 1日の活動時間 (起床〜就寝) を分単位で定義
  /// 基本: 6:30 - 23:00 = 990分 (16.5h)
  static const int _totalActiveMinutes = 990;

  /// PlanC: 6:30 - 21:00 = 870分 (14.5h, 早寝)
  static const int _survivalActiveMinutes = 870;

  TimeRoiAdvice generate({
    required DadProfile profile,
    required ConditionScore condition,
    required PlanMode mode,
    required DateTime date,
  }) {
    final isSportDay = profile.sportDaysOfWeek.contains(date.weekday);
    final allocations = _calculateAllocations(mode, isSportDay, profile);
    final highRoi = _highRoiActions(mode, isSportDay);
    final lowRoi = _lowRoiToSkip(mode);

    return TimeRoiAdvice(
      allocations: allocations,
      currentMode: mode,
      strategy: _buildStrategy(mode, isSportDay),
      highRoiActions: highRoi,
      lowRoiToSkip: lowRoi,
    );
  }

  Map<LifeRole, TimeAllocation> _calculateAllocations(
      PlanMode mode, bool isSportDay, DadProfile profile) {
    final total =
        mode == PlanMode.planC ? _survivalActiveMinutes : _totalActiveMinutes;

    switch (mode) {
      case PlanMode.planA:
        return _planAAllocations(total, isSportDay, profile);
      case PlanMode.planB:
        return _planBAllocations(total, isSportDay, profile);
      case PlanMode.planC:
        return _planCAllocations(total, profile);
    }
  }

  Map<LifeRole, TimeAllocation> _planAAllocations(
      int total, bool isSportDay, DadProfile profile) {
    final sportMinutes = isSportDay ? 120 : 30;
    final workMinutes = 480; // 8h
    final familyMinutes = total - workMinutes - sportMinutes;

    return {
      LifeRole.engineer: TimeAllocation(
        role: LifeRole.engineer,
        minutes: workMinutes,
        percentage: (workMinutes / total * 100),
        focus: 'ディープワーク2ブロック (90分 x 2) を午前に配置。'
            '午後はMTG・レビュー等のライトワーク。ポモドーロ25/5で集中を維持。',
      ),
      LifeRole.papa: TimeAllocation(
        role: LifeRole.papa,
        minutes: familyMinutes,
        percentage: (familyMinutes / total * 100),
        focus: isSportDay
            ? '朝の準備 + 夕食〜寝かしつけ。スポーツで不在分を'
                '「質」でカバー: 寝かしつけ時の読み聞かせに集中。'
            : '朝夕の食事・入浴・寝かしつけ + 子どもとの遊び時間。'
                '「ながら家事」でスキマ時間を最大活用。',
      ),
      LifeRole.athlete: TimeAllocation(
        role: LifeRole.athlete,
        minutes: sportMinutes,
        percentage: (sportMinutes / total * 100),
        focus: isSportDay
            ? 'フットサル本番 (90分) + ウォームアップ/クールダウン (30分)。'
                '全力を出してOKな日。'
            : '朝の自重トレーニング (25分) + ストレッチ (5分)。'
                'フットサルのための体づくり投資。',
      ),
    };
  }

  Map<LifeRole, TimeAllocation> _planBAllocations(
      int total, bool isSportDay, DadProfile profile) {
    final sportMinutes = isSportDay ? 75 : 15;
    final workMinutes = 420; // 7h (ペースダウン)
    final familyMinutes = total - workMinutes - sportMinutes;

    return {
      LifeRole.engineer: TimeAllocation(
        role: LifeRole.engineer,
        minutes: workMinutes,
        percentage: (workMinutes / total * 100),
        focus: 'ディープワーク1ブロック (90分) のみ午前に。'
            'それ以外はルーチンタスク・レビュー。「今日やらないこと」を決めるのが最重要。',
      ),
      LifeRole.papa: TimeAllocation(
        role: LifeRole.papa,
        minutes: familyMinutes,
        percentage: (familyMinutes / total * 100),
        focus: '基本の家事育児 + リカバリー時間を確保。'
            'パートナーに事情を共有し、可能であれば家事を一部委託。'
            '「完璧な親」より「持続可能な親」を目指す日。',
      ),
      LifeRole.athlete: TimeAllocation(
        role: LifeRole.athlete,
        minutes: sportMinutes,
        percentage: (sportMinutes / total * 100),
        focus: isSportDay
            ? '強度を70%に落としてフットサル参加。無理なら見学でもOK。'
                '参加すること自体がメンタルヘルスに貢献。'
            : '軽いストレッチのみ。体が「動きたくない」と言っているなら休むのが正解。',
      ),
    };
  }

  Map<LifeRole, TimeAllocation> _planCAllocations(
      int total, DadProfile profile) {
    final workMinutes = profile.isRemoteWork ? 300 : 420; // 5h or 7h
    final familyMinutes = total - workMinutes;

    return {
      LifeRole.engineer: TimeAllocation(
        role: LifeRole.engineer,
        minutes: workMinutes,
        percentage: (workMinutes / total * 100),
        focus: profile.isRemoteWork
            ? '最重要タスク1つだけに集中。他は全てリスケ or 委任。'
                '上司/チームに「今日は体調不良で稼働率50%」と早めに連絡。'
            : '出勤が必要なら最低限の業務のみ。可能なら午後休 or 在宅切替を検討。',
      ),
      LifeRole.papa: TimeAllocation(
        role: LifeRole.papa,
        minutes: familyMinutes,
        percentage: (familyMinutes / total * 100),
        focus: '子どもの安全確保が最優先。家事は最低限（洗い物・洗濯最小限のみ）。'
            '手抜きOK・外注OK・冷凍食品OK。今日の1日を全員健康で終えれば大勝利。',
      ),
      LifeRole.athlete: TimeAllocation(
        role: LifeRole.athlete,
        minutes: 0,
        percentage: 0,
        focus: '今日は完全休息。スポーツの予定があってもスキップ。'
            'この判断ができること自体がアスリートとしての成熟。'
            '体は「休んでほしい」とサインを出しています。',
      ),
    };
  }

  List<String> _highRoiActions(PlanMode mode, bool isSportDay) {
    switch (mode) {
      case PlanMode.planA:
        return [
          '午前中のディープワーク (90分): エンジニアとしてのアウトプットの80%はここで生まれる',
          '子どもとの食事時間: 「ながら」せず目を見て話す10分が1時間の遊びに匹敵',
          if (isSportDay)
            'フットサル: 身体的健康 + ストレス解消 + 社会的つながりの3重ROI'
          else
            '朝の自重トレ: 25分の投資で午前中の集中力が2倍に',
          '就寝前の10分読書: 翌日のインプット品質を底上げ',
        ];
      case PlanMode.planB:
        return [
          '午前中のディープワーク1本: 疲労時でもこの1ブロックだけは死守',
          '昼の仮眠15分: 午後の生産性を34%回復させる最高のROI行動',
          '子どもの寝かしつけへの集中参加: 短時間でも「質」で補う',
          '21時以降のブルーライトカット: 翌日の回復速度を左右する',
        ];
      case PlanMode.planC:
        return [
          '子どもの安全確保: 最優先事項。他のすべてに優先する',
          '最重要の仕事タスク1つだけを完了: これができれば上出来',
          '仮眠 (取れるタイミングで): 5分でも脳のリセットに',
          '早寝: 今日の最大の投資。明日の自分を救う行動',
        ];
    }
  }

  List<String> _lowRoiToSkip(PlanMode mode) {
    switch (mode) {
      case PlanMode.planA:
        return [
          'SNSの無目的スクロール (30分→0分で1日30分回収)',
          'ニュースの過度なチェック (朝1回で十分)',
          '完璧な料理 (80点の料理でOK、その20分で子どもと遊べる)',
        ];
      case PlanMode.planB:
        return [
          '非必須のMTG (延期 or 非同期化)',
          '家事の完璧主義 (洗濯は畳まずカゴのままでOK)',
          'スポーツ以外の付き合いの約束 (リスケを遠慮なく)',
          'コードの過度なリファクタリング (動けばOKの日)',
        ];
      case PlanMode.planC:
        return [
          'すべてのオプショナルタスク',
          'すべての運動',
          '完璧な食事の準備',
          '洗濯物を畳む、床を掃除する等の非緊急家事',
          '返信を急がないSlack/メール',
        ];
    }
  }

  String _buildStrategy(PlanMode mode, bool isSportDay) {
    switch (mode) {
      case PlanMode.planA:
        return 'エンジニア・パパ・アスリートの3役を高い水準で回す日。'
            '鍵は「ディープワークの死守」と「家族時間の質」。'
            '量より質、完璧より持続を意識しましょう。';
      case PlanMode.planB:
        return '「やらないことリスト」が今日の生産性を決める。'
            'エンジニアとしては最重要タスク1つに絞り、パパとしては基本動作のみ。'
            'アスリートとしては回復に専念。この配分が3日後のパフォーマンスを最大化。';
      case PlanMode.planC:
        return '今日のROI計算は単純: 「全員が生きて1日を終える」= 最大リターン。'
            'それ以外はすべてボーナス。仕事は最重要1タスクのみ。'
            '運動は完全スキップ。家事は最低限。早寝が最高の投資。';
    }
  }
}
