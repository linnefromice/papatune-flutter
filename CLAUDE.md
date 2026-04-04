# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PapaTune** — 育児中の父親向けの日々のコンディション管理・プラン生成アプリ（Flutter版）。
睡眠不足や子どもの体調不良などの「カオスイベント」に応じて、3段階のプランモード（通常/睡眠不足/サバイバル）でタスクを自動調整する。

React Native版 (`papatune-rn`) と同一コンセプトの Flutter 実装。

## Tech Stack

- **Framework:** Flutter (Dart) SDK ^3.10.7
- **Flutter Version:** FVM で管理 (`.fvmrc` = stable)
- **State Management:** Provider ^6.1.2
- **Storage:** SharedPreferences ^2.3.4 (JSON シリアライズ)
- **Calendar:** table_calendar ^3.1.3
- **Other:** intl ^0.19.0 (日付フォーマット), uuid ^4.5.1 (ID生成)
- **Design:** Material 3 (seed color: #2E7D6F)
- **CI/CD:** GitHub Actions → Firebase App Distribution (internal-testers)

## Commands

```bash
# Flutter は FVM 経由で実行する
# fvm flutter が PATH 問題で失敗する場合はフルパスで実行:
#   /home/paru/fvm/versions/stable/bin/flutter

fvm flutter pub get          # 依存関係インストール
fvm flutter run              # 実行
fvm flutter analyze          # 静的解析
fvm flutter test             # テスト
fvm flutter build apk        # Android APK ビルド
```

## Architecture

### データフロー

Provider パターンで状態管理。モデルは immutable (toJson/fromJson でシリアライズ)。
`ChangeNotifierProxyProvider` で DisruptionProvider → ConditionProvider のリアクティブ連携。

### レイヤー構成

- **Models** (`lib/models/`):
  - DadProfile, ChildProfile — ユーザープロファイル
  - DailyPlan, PlanTask — 日次プラン・タスク (isDone で完了管理)
  - PlanTemplate, TemplateTask — 名前付きテンプレート (タイトル + timeSlot)
  - DisruptionLog, ConditionScore — カオスイベント・コンディション
- **Enums** (`lib/enums/`): PlanMode (planA/B/C), WorkStyle, DisruptionType, HouseholdDuty
- **Providers** (`lib/providers/`):
  - `ProfileProvider` — プロファイル CRUD
  - `PlanProvider` — プラン生成・テンプレート CRUD・曜日割り当て・日付指定タスク操作
  - `DisruptionProvider` — カオスイベント記録・削除
  - `ConditionProvider` — コンディションスコア算出 (ProxyProvider 経由)
- **Services** (`lib/services/`):
  - `StorageService` — SharedPreferences ラッパー (30日自動プルーニング, テンプレート/曜日割り当て永続化, 旧形式マイグレーション)
  - `ConditionCalculator` — 直近24hのカオスイベントからスコア算出 (0-100)
  - `PlanGenerator` — プロファイル+コンディションからモード別タスク生成 (テンプレート未設定時のフォールバック)
  - `CoachMessageService` — コンテキスト依存の励ましメッセージ
- **Screens** (`lib/screens/`):
  - `onboarding/` — 5ステップ初期設定 (子ども → 勤務 → 家事 → 平日プラン → 休日プラン[スキップ可])
  - `dashboard/` — メイン画面 (BottomNav: 今日/記録/設定)
  - `settings/` — テンプレート一覧・編集・曜日割り当て

### テンプレートシステム

名前付き複数テンプレート + 曜日ごとの割り当て。
- `PlanTemplate` — id, name, List<TemplateTask> (title + timeSlot)
- `Map<int, String>` — 曜日(1-7) → テンプレートID
- プラン生成時: 当日の曜日に割り当てられたテンプレートを使用、未設定なら PlanGenerator にフォールバック
- オンボーディングで平日テンプレート(必須) + 休日テンプレート(任意) を作成
- 設定画面でテンプレートの追加・編集・複製・削除、曜日一括割り当てが可能

### コアロジック: コンディションスコア

100点満点から直近24hのカオスイベントの impactScore を減算。
- 70以上 → planA (通常モード)
- 40-69 → planB (睡眠不足モード)
- 40未満 → planC (サバイバルモード)

ディスラプション記録時に SnackBar で「取り消し」可能。直近24h履歴をスワイプ削除可。

### カレンダー記録

「記録」タブ (table_calendar) で日別プランの履歴を表示。
- カレンダー上でプランがある日にドットマーカー
- 日付タップで詳細表示 (モード、達成率、タスク一覧)
- 過去の日のタスクもチェック/アンチェック可能

### ナビゲーション

`Navigator.push` + `pushReplacementNamed` による命令的ルーティング。
ルート: `/` (条件分岐), `/onboarding`, `/dashboard`
設定サブ画面は `Navigator.push` で直接遷移。

## Directory Structure

```
lib/
├── main.dart              # エントリポイント (MultiProvider 登録, マイグレーション)
├── app_theme.dart         # Material 3 テーマ定義
├── constants/
│   ├── app_values.dart    # 閾値・設定値
│   └── task_templates.dart # タスクカタログ (7カテゴリ, デフォルトテンプレート)
├── enums/                 # DisruptionType, HouseholdDuty, PlanMode, WorkStyle
├── models/
│   ├── dad_profile.dart, child_profile.dart
│   ├── daily_plan.dart, plan_task.dart
│   ├── plan_template.dart  # PlanTemplate + TemplateTask
│   ├── disruption_log.dart, condition_score.dart
├── providers/             # Provider (状態管理)
├── screens/
│   ├── onboarding/        # 5ステップオンボーディング
│   │   └── pages/         # plan_template_page.dart (再利用可能)
│   ├── dashboard/         # メインダッシュボード (pages/, widgets/)
│   └── settings/          # テンプレート一覧/編集, 曜日割り当て
├── services/              # ビジネスロジック
└── utils/date_utils.dart  # DateTime 拡張
```

## Key Constants (lib/constants/app_values.dart)

- `onboardingPageCount`: 5
- `conditionPlanAThreshold`: 70
- `conditionPlanBThreshold`: 40
- `maxHistoryDays`: 30
- `reviewPeriodDays`: 7

## Testing

テストは `test/` 配下。100+ テストケース。

```bash
fvm flutter test                           # 全テスト
fvm flutter test test/widget_test.dart     # 単体指定
```

テストファイル:
- `test/widget_test.dart` — 起動テスト
- `test/models/` — PlanTask モデルテスト
- `test/providers/` — 全 Provider テスト (plan, profile, condition, disruption)
- `test/services/` — StorageService, ConditionCalculator, PlanGenerator, CoachMessageService
- `test/utils/` — DateFormatting テスト

## CI/CD

`.github/workflows/distribute.yml`:
- main push でトリガー
- flutter analyze → flutter test → APK ビルド → Firebase App Distribution (internal-testers)
- Secrets: `FIREBASE_APP_ID`, `FIREBASE_SERVICE_ACCOUNT_KEY`
