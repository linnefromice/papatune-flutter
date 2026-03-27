import '../enums/autonomic_action.dart';
import '../enums/plan_mode.dart';
import '../models/autonomic_advice.dart';
import '../models/condition_score.dart';
import '../models/dad_profile.dart';

/// 【観点4】自律神経のスイッチング
/// 交感/副交感神経の切り替え制御（カフェインタイミング・入浴・呼吸法等）
class AutonomicSwitchService {
  AutonomicAdvice generate({
    required DadProfile profile,
    required ConditionScore condition,
    required PlanMode mode,
    required DateTime date,
  }) {
    final isSportDay = profile.sportDaysOfWeek.contains(date.weekday);
    final schedule = <AutonomicScheduleItem>[];

    if (mode == PlanMode.planC) {
      return _survivalSchedule();
    }

    // 朝: 覚醒フェーズ
    schedule.addAll(_morningActivation(mode, profile.isRemoteWork));

    // 午前: 集中フェーズ
    schedule.addAll(_focusPhase(mode));

    // 午後: リフレッシュ → 集中
    schedule.addAll(_afternoonPhase(mode, isSportDay));

    // スポーツ前: 交感神経活性化
    if (isSportDay) {
      schedule.addAll(_preSportActivation());
    }

    // 夕方〜夜: 副交感神経への切り替え
    schedule.addAll(_eveningWindDown(mode, isSportDay));

    // 就寝前: 完全リラックス
    schedule.addAll(_bedtimeRoutine(mode));

    final caffeineDeadline = isSportDay ? '15:00' : '14:00';

    return AutonomicAdvice(
      schedule: schedule,
      caffeineDeadline: caffeineDeadline,
      summary: _buildSummary(mode, isSportDay),
    );
  }

  AutonomicAdvice _survivalSchedule() {
    return AutonomicAdvice(
      schedule: [
        AutonomicScheduleItem(
          timeSlot: '07:00',
          action: AutonomicAction.coldFaceWash,
          reason: '最低限の覚醒トリガー。冷水で顔を洗うだけでノルアドレナリンが分泌。',
          targetMode: AutonomicMode.sympathetic,
        ),
        AutonomicScheduleItem(
          timeSlot: '07:15',
          action: AutonomicAction.caffeine,
          reason: 'サバイバルモードではカフェインに頼ってOK。ただし12時以降は避ける。',
          targetMode: AutonomicMode.sympathetic,
        ),
        AutonomicScheduleItem(
          timeSlot: '12:30',
          action: AutonomicAction.nsdr,
          reason: 'NSDR (Non-Sleep Deep Rest) で脳を強制リセット。'
              'YouTubeで「ヨガニドラ 10分」で検索。横になれなくても座って聞くだけでOK。',
          targetMode: AutonomicMode.parasympathetic,
        ),
        AutonomicScheduleItem(
          timeSlot: '20:00',
          action: AutonomicAction.warmBath,
          reason: '温浴で副交感神経を優位にし、入眠を促進。子どもとの入浴時間を活用。',
          targetMode: AutonomicMode.parasympathetic,
        ),
        AutonomicScheduleItem(
          timeSlot: '21:00',
          action: AutonomicAction.dimLight,
          reason: '照明を落としてメラトニン分泌を促進。スマホのブルーライトも最小限に。',
          targetMode: AutonomicMode.parasympathetic,
        ),
      ],
      caffeineDeadline: '12:00',
      summary: 'サバイバルモード: 最低限の覚醒を維持しつつ、夜の回復を最大化するスケジュール。'
          'カフェインは午前中のみ。午後は副交感神経モードに切り替えて、早期の入眠を目指します。',
    );
  }

  List<AutonomicScheduleItem> _morningActivation(
      PlanMode mode, bool isRemoteWork) {
    return [
      AutonomicScheduleItem(
        timeSlot: '06:30',
        action: AutonomicAction.brightLight,
        reason: '朝の光が網膜に入ると視交叉上核が刺激され、'
            'コルチゾール分泌のパルスが起こります。これがサーカディアンリズムの起点。',
        targetMode: AutonomicMode.sympathetic,
      ),
      if (mode == PlanMode.planA)
        AutonomicScheduleItem(
          timeSlot: '06:35',
          action: AutonomicAction.coldShower,
          reason: '冷水シャワー30秒でノルアドレナリンが最大530%上昇（研究データ）。'
              '朝の覚醒を一気に加速し、午前中の集中力が段違いに。',
          targetMode: AutonomicMode.sympathetic,
        ),
      if (mode == PlanMode.planB)
        AutonomicScheduleItem(
          timeSlot: '06:35',
          action: AutonomicAction.coldFaceWash,
          reason: '全身冷水は疲労時にはストレス過多。顔だけの冷水で十分な覚醒効果あり。',
          targetMode: AutonomicMode.sympathetic,
        ),
      AutonomicScheduleItem(
        timeSlot: isRemoteWork ? '08:00' : '07:30',
        action: AutonomicAction.caffeine,
        reason: '起床後90分で摂取がベスト（コルチゾールの自然なピーク後）。'
            '早すぎるカフェインはコルチゾールと競合して効果減。',
        targetMode: AutonomicMode.sympathetic,
      ),
    ];
  }

  List<AutonomicScheduleItem> _focusPhase(PlanMode mode) {
    return [
      AutonomicScheduleItem(
        timeSlot: '09:00',
        action: AutonomicAction.boxBreathing,
        reason: 'ワーク開始時にボックス呼吸法で「意図的な覚醒」状態を作る。'
            '4秒吸う→4秒止める→4秒吐く→4秒止める を4サイクル。'
            'Navy SEALsも使うストレス下の集中テクニック。',
        targetMode: AutonomicMode.sympathetic,
      ),
    ];
  }

  List<AutonomicScheduleItem> _afternoonPhase(
      PlanMode mode, bool isSportDay) {
    return [
      if (mode == PlanMode.planB)
        AutonomicScheduleItem(
          timeSlot: '13:00',
          action: AutonomicAction.nsdr,
          reason: '食後の副交感神経優位を利用してNSDRで脳をリセット。'
              '10分のNSDRは2時間の睡眠に匹敵するリカバリー効果。',
          targetMode: AutonomicMode.parasympathetic,
        ),
      AutonomicScheduleItem(
        timeSlot: '14:00',
        action: AutonomicAction.noCaffeine,
        reason: 'カフェインの半減期は5-6時間。14時以降のカフェインは23時時点でも体内に25%残留し、'
            '入眠を20分遅延させます。',
        targetMode: AutonomicMode.parasympathetic,
      ),
      if (!isSportDay)
        AutonomicScheduleItem(
          timeSlot: '15:00',
          action: AutonomicAction.powerPose,
          reason: '15時の眠気対策。パワーポーズ2分でコルチゾール↓20%、テストステロン↑20%。'
              '立ち上がって胸を張り、腰に手を当てるだけ。',
          targetMode: AutonomicMode.sympathetic,
        ),
    ];
  }

  List<AutonomicScheduleItem> _preSportActivation() {
    return [
      AutonomicScheduleItem(
        timeSlot: '16:30',
        action: AutonomicAction.boxBreathing,
        reason: 'スポーツ前の「ゾーンイン」。呼吸で交感神経を適度に活性化し、'
            '反応速度と判断力を最適な状態にチューニング。',
        targetMode: AutonomicMode.sympathetic,
      ),
    ];
  }

  List<AutonomicScheduleItem> _eveningWindDown(
      PlanMode mode, bool isSportDay) {
    return [
      AutonomicScheduleItem(
        timeSlot: isSportDay ? '19:30' : '19:00',
        action: AutonomicAction.warmBath,
        reason: '入浴で深部体温を一時的に上げ、その後の体温低下で自然な眠気を誘導。'
            '38-40度、15分が最適。子どもと一緒の入浴なら一石二鳥。',
        targetMode: AutonomicMode.parasympathetic,
      ),
      if (isSportDay)
        AutonomicScheduleItem(
          timeSlot: '19:00',
          action: AutonomicAction.gentleStretch,
          reason: '運動後の副交感神経への切り替え。スポーツで上がった交感神経を'
              'ゆるストレッチでゆっくり下げる。急激な切り替えは避ける。',
          targetMode: AutonomicMode.parasympathetic,
        ),
    ];
  }

  List<AutonomicScheduleItem> _bedtimeRoutine(PlanMode mode) {
    final bedtime = mode == PlanMode.planA ? '22:30' : '21:30';
    return [
      AutonomicScheduleItem(
        timeSlot: bedtime,
        action: AutonomicAction.dimLight,
        reason: '就寝1時間前から照明を暖色系に切り替え、照度を50%以下に。'
            'これだけでメラトニン分泌が30分早まります。',
        targetMode: AutonomicMode.parasympathetic,
      ),
      AutonomicScheduleItem(
        timeSlot: mode == PlanMode.planA ? '22:45' : '21:45',
        action: AutonomicAction.deepBreathing,
        reason: '4-7-8呼吸法（4秒吸う→7秒止める→8秒吐く）x 4サイクル。'
            '副交感神経を強力に活性化し、入眠までの時間を短縮。'
            'アンドリュー・ワイル博士考案の「天然の入眠剤」。',
        targetMode: AutonomicMode.parasympathetic,
      ),
    ];
  }

  String _buildSummary(PlanMode mode, bool isSportDay) {
    if (isSportDay) {
      return '今日はスポーツ日。朝〜午後は交感神経優位で仕事とスポーツのパフォーマンスを最大化し、'
          '運動後は意識的に副交感神経に切り替えてリカバリーと睡眠の質を確保します。';
    }
    if (mode == PlanMode.planB) {
      return '疲労時は自律神経のバランスが乱れやすい状態。'
          '朝の最低限の覚醒 → 午後のNSDR → 夜の早めの副交感神経切り替えで、'
          '限られたエネルギーを効率的に使いましょう。';
    }
    return '好調日の自律神経戦略: 朝の冷水シャワーで一気に覚醒 → '
        'ボックス呼吸で集中 → 14時以降はカフェインカット → '
        '入浴と呼吸法で副交感神経に切り替え。メリハリが明日のパフォーマンスも作ります。';
  }
}
