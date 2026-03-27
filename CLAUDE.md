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

### レイヤー構成

- **Models** (`lib/models/`): DadProfile, ChildProfile, DailyPlan, PlanTask, DisruptionLog, ConditionScore
- **Enums** (`lib/enums/`): PlanMode (planA/B/C), WorkStyle, DisruptionType, HouseholdDuty
- **Providers** (`lib/providers/`): ProfileProvider, PlanProvider, DisruptionProvider, ConditionProvider
- **Services** (`lib/services/`):
  - `StorageService` — SharedPreferences ラッパー (30日自動プルーニング)
  - `ConditionCalculator` — 直近24hのカオスイベントからスコア算出 (0-100)
  - `PlanGenerator` — プロファイル+コンディションからモード別タスク生成
  - `CoachMessageService` — コンテキスト依存の励ましメッセージ
- **Screens** (`lib/screens/`):
  - `onboarding/` — 初期設定フロー
  - `dashboard/` — メイン画面 (BottomNav: ホーム/レビュー/設定)

### コアロジック: コンディションスコア

100点満点から直近24hのカオスイベントの impactScore を減算。
- 70以上 → planA (通常モード)
- 40-69 → planB (睡眠不足モード)
- 40未満 → planC (サバイバルモード)

### ナビゲーション

`Navigator.push` + `pushReplacementNamed` による命令的ルーティング。
ルート: `/` (条件分岐), `/onboarding`, `/dashboard`

## Directory Structure

```
lib/
├── main.dart              # エントリポイント (MultiProvider 登録)
├── app_theme.dart         # Material 3 テーマ定義
├── constants/app_values.dart
├── enums/                 # DisruptionType, HouseholdDuty, PlanMode, WorkStyle
├── models/                # DadProfile, ChildProfile, DailyPlan, etc.
├── providers/             # Provider (状態管理)
├── screens/
│   ├── onboarding/        # オンボーディングフロー
│   └── dashboard/         # メインダッシュボード (pages/, widgets/)
├── services/              # ビジネスロジック
└── utils/date_utils.dart  # DateTime 拡張
```

## Key Constants (lib/constants/app_values.dart)

- `conditionPlanAThreshold`: 70
- `conditionPlanBThreshold`: 40
- `maxHistoryDays`: 30
- `reviewPeriodDays`: 7

## Testing

テストは `test/` 配下。現在 `widget_test.dart` のみ (起動テスト)。

```bash
fvm flutter test                           # 全テスト
fvm flutter test test/widget_test.dart     # 単体指定
```

## CI/CD

`.github/workflows/distribute.yml`:
- main push でトリガー
- APK ビルド → Firebase App Distribution (internal-testers)
- Secrets: `FIREBASE_APP_ID`, `FIREBASE_SERVICE_ACCOUNT_KEY`
