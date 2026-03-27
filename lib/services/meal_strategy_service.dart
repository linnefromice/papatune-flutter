import '../enums/meal_timing.dart';
import '../enums/plan_mode.dart';
import '../models/condition_score.dart';
import '../models/meal_advice.dart';

/// 【観点3】食事による脳のハック
/// 血糖値スパイク回避・タンパク質/食物繊維重視の食事戦略
class MealStrategyService {
  MealAdvice generate({
    required ConditionScore condition,
    required PlanMode mode,
    required bool isSportDay,
    required bool isRemoteWork,
  }) {
    final meals = <MealRecommendation>[];

    // 朝食: 全モード共通（血糖値安定が最重要）
    meals.add(_breakfast(mode));

    // 午前おやつ: PlanA/B で追加
    if (mode != PlanMode.planC) {
      meals.add(_morningSnack(mode));
    }

    // 昼食
    meals.add(_lunch(mode, isSportDay));

    // 午後おやつ
    if (mode != PlanMode.planC) {
      meals.add(_afternoonSnack(isSportDay));
    }

    // スポーツ日: 運動前後の栄養
    if (isSportDay) {
      meals.add(_preSport());
      meals.add(_postSport());
    }

    // 夕食
    meals.add(_dinner(mode, isSportDay));

    return MealAdvice(
      meals: meals,
      strategy: _buildStrategy(mode, isSportDay),
      isSportDay: isSportDay,
      bloodSugarTip: _bloodSugarTip(mode),
    );
  }

  MealRecommendation _breakfast(PlanMode mode) {
    if (mode == PlanMode.planC) {
      return MealRecommendation(
        timing: MealTiming.breakfast,
        recommendation: 'エネルギー確保最優先。食べやすいもので炭水化物+タンパク質を。',
        goodFoods: ['おにぎり', '卵焼き', 'バナナ', 'ヨーグルト'],
        avoidFoods: ['菓子パンのみ（血糖値スパイクで昼前に急降下）'],
        note: '子どもの準備で忙しくても、何かしら口に入れることが最優先。',
      );
    }

    return MealRecommendation(
      timing: MealTiming.breakfast,
      recommendation: '食物繊維 → タンパク質 → 炭水化物の順で食べる（血糖値スパイク回避）',
      goodFoods: [
        'サラダ/野菜スティック（食物繊維ファースト）',
        '卵/納豆/ギリシャヨーグルト（タンパク質20g目標）',
        '玄米/全粒粉パン（低GI炭水化物）',
        'MCTオイル入りコーヒー（脂質で腹持ちUP）',
      ],
      avoidFoods: [
        '白米のみ/食パンのみ（血糖値急上昇→10時前にクラッシュ）',
        '甘いシリアル',
        'フルーツジュース（果糖液は血糖値スパイクの元凶）',
      ],
      note: mode == PlanMode.planA
          ? '好調時こそ「食べ順」を意識。午前中の集中力が段違いに。'
          : '疲労時は特にタンパク質を優先。セロトニン合成に必要なトリプトファンを確保。',
    );
  }

  MealRecommendation _morningSnack(PlanMode mode) {
    return MealRecommendation(
      timing: MealTiming.morningSnack,
      recommendation: '血糖値を安定させる間食で集中力を維持',
      goodFoods: [
        'ナッツ（アーモンド10粒が目安）',
        'ハイカカオチョコレート（70%以上）',
        'チーズ',
      ],
      avoidFoods: ['砂糖入りのお菓子', '清涼飲料水'],
      note: '10時頃に小さな間食を入れることで昼食までの血糖値を安定維持。'
          '「空腹→ドカ食い」パターンを防ぐ。',
    );
  }

  MealRecommendation _lunch(PlanMode mode, bool isSportDay) {
    if (mode == PlanMode.planC) {
      return MealRecommendation(
        timing: MealTiming.lunch,
        recommendation: 'エネルギー補給最優先。食べられるものを食べる。',
        goodFoods: ['うどん/そば + 卵', 'カレーライス', 'おにぎり + 味噌汁'],
        note: 'サバイバルモードでは栄養バランスより「食べること」自体が重要。',
      );
    }

    return MealRecommendation(
      timing: MealTiming.lunch,
      recommendation: '午後の眠気を最小化する食事設計',
      goodFoods: [
        'サラダ（食物繊維ファースト）',
        '鶏胸肉/魚/豆腐（タンパク質メイン）',
        '玄米/蕎麦（低GI炭水化物は少なめに）',
      ],
      avoidFoods: [
        '大盛り白米（午後の血糖値クラッシュの原因）',
        'ラーメン+白米（炭水化物 x 炭水化物）',
        '揚げ物の大量摂取',
      ],
      note: isSportDay
          ? 'スポーツ日は炭水化物をやや多めに。グリコーゲン補充が午後のパフォーマンスを左右。'
          : '炭水化物を拳1個分に抑えると午後の眠気が激減。「野菜→肉→ご飯」の順で。',
    );
  }

  MealRecommendation _afternoonSnack(bool isSportDay) {
    if (isSportDay) {
      return MealRecommendation(
        timing: MealTiming.afternoonSnack,
        recommendation: '運動2時間前のエネルギーチャージ',
        goodFoods: [
          'バナナ（即効性のエネルギー）',
          'おにぎり1個',
          'エネルギーバー',
        ],
        note: '運動パフォーマンスを最大化するための「プレフューエリング」。'
            '消化に負担が少ないものを選択。',
      );
    }

    return MealRecommendation(
      timing: MealTiming.afternoonSnack,
      recommendation: '15時の集中力低下を防ぐスマートスナック',
      goodFoods: [
        'プロテインバー',
        'ナッツ + ドライフルーツ',
        'ゆで卵',
      ],
      avoidFoods: ['コンビニスイーツ（血糖値スパイク→16時にクラッシュ）'],
      note: '15時は生理的に眠くなる時間帯。タンパク質+良質な脂質で乗り切る。',
    );
  }

  MealRecommendation _preSport() {
    return MealRecommendation(
      timing: MealTiming.preSport,
      recommendation: '運動60分前: 消化が軽く即効性のあるエネルギー補給',
      goodFoods: [
        'バナナ',
        'はちみつトースト',
        'スポーツドリンク (500ml)',
      ],
      avoidFoods: ['脂質の多い食事（消化に時間がかかる）', '食物繊維が多すぎる食品'],
      note: '胃に残ると運動パフォーマンスが落ちるため、消化の良いものを少量。',
    );
  }

  MealRecommendation _postSport() {
    return MealRecommendation(
      timing: MealTiming.postSport,
      recommendation: '運動後30分以内のゴールデンタイム: タンパク質+炭水化物で回復加速',
      goodFoods: [
        'プロテインシェイク + バナナ',
        '鶏胸肉サンドイッチ',
        'ギリシャヨーグルト + グラノーラ',
      ],
      note: 'タンパク質20-30g + 炭水化物30-50gが黄金比。'
          '筋グリコーゲンの回復速度が2倍に。エンジニアの脳にもグリコーゲンは必須。',
    );
  }

  MealRecommendation _dinner(PlanMode mode, bool isSportDay) {
    if (mode == PlanMode.planC) {
      return MealRecommendation(
        timing: MealTiming.dinner,
        recommendation: '簡単に作れて栄養が取れるもの。完璧を目指さない。',
        goodFoods: ['具沢山味噌汁 + おにぎり', '冷凍うどん + 卵', 'レトルトカレー + サラダ'],
        note: 'サバイバルモードでは手間をかけないことが正解。子どもと一緒に食べられればなお良し。',
      );
    }

    return MealRecommendation(
      timing: MealTiming.dinner,
      recommendation: '睡眠の質を高める夕食設計',
      goodFoods: [
        '鮭/マグロ（トリプトファン豊富→セロトニン→メラトニン変換）',
        '味噌汁（GABA含有の発酵食品）',
        '温野菜（消化に優しい）',
        'ご飯少なめ（血糖値の急降下による中途覚醒を防ぐ）',
      ],
      avoidFoods: [
        '21時以降の食事（消化に3-4時間かかり睡眠の質低下）',
        'アルコール（入眠は早まるが中途覚醒リスク3倍）',
        '辛い食品（深部体温上昇で入眠困難）',
      ],
      note: isSportDay
          ? '運動後は回復のためにやや多めに摂取OK。ただし就寝3時間前までに。'
          : '就寝3時間前までに食べ終えるのが理想。難しければ軽めの夕食に。',
    );
  }

  String _buildStrategy(PlanMode mode, bool isSportDay) {
    if (mode == PlanMode.planC) {
      return '今日は「食べること」自体が最大のタスク。栄養バランスは二の次で、'
          'エネルギーを確保することに集中。手抜きOK、冷凍食品OK、外食OK。';
    }
    if (isSportDay) {
      return '運動日の栄養戦略: 午前中にタンパク質と食物繊維で血糖値を安定させ、'
          '午後は運動に向けてグリコーゲンを蓄積。運動後30分以内のリカバリー栄養が鍵。';
    }
    return '脳のパフォーマンスを最大化する食事戦略: 「食べ順」「間食」「タンパク質」の3点を意識。'
        '血糖値の乱高下を防ぐことが、集中力・判断力・気分の安定に直結します。';
  }

  String _bloodSugarTip(PlanMode mode) {
    if (mode == PlanMode.planC) {
      return '今日は血糖値管理より「食べること」を優先。明日以降に戦略的な食事を再開。';
    }
    return '食べ順のルール: ①野菜/食物繊維 → ②タンパク質 → ③炭水化物。'
        'この順番を守るだけで食後血糖値の上昇が40%抑制される研究結果あり。'
        'エンジニアの「午後2時のフォグ」を解消する最も簡単な方法です。';
  }
}
