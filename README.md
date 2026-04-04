# PapaTune

育児中の父親向けの日々のコンディション管理・プラン生成アプリ（Flutter版）。

睡眠不足や子どもの体調不良などの「カオスイベント」に応じて、3段階のプランモード（通常/睡眠不足/サバイバル）でタスクを自動調整します。

## Features

- **コンディション管理** — カオスイベント（夜泣き、体調不良等）を記録し、0-100のスコアで体調を可視化
- **3段階プランモード** — スコアに応じて Plan A(通常) / B(睡眠不足) / C(サバイバル) を自動切替
- **テンプレートシステム** — 複数の名前付きテンプレートを作成し、曜日ごとに割り当て
- **カレンダー記録** — 日別のプラン達成状況をカレンダーで確認・編集
- **オンボーディング** — 5ステップの初期設定（子ども/勤務スタイル/家事/平日プラン/休日プラン）

## Tech Stack

| カテゴリ | 技術 |
|---------|------|
| Framework | Flutter (Dart) SDK ^3.10.7 |
| Flutter Version | FVM (stable) |
| State Management | Provider ^6.1.2 |
| Storage | SharedPreferences ^2.3.4 |
| Calendar | table_calendar ^3.1.3 |
| Design | Material 3 |
| CI/CD | GitHub Actions + Firebase App Distribution |

## Getting Started

### Prerequisites

- [FVM](https://fvm.app/) (Flutter Version Management)
- Android SDK (for Android builds)

### Setup

```bash
# Install Flutter via FVM
fvm install stable
fvm use stable

# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run
```

### Development

```bash
fvm flutter analyze          # Static analysis
fvm flutter test             # Run tests (100+ test cases)
fvm flutter build apk        # Build Android APK
```

## Architecture

Provider パターンで状態管理。モデルは immutable。

```
lib/
├── models/          # Data models (DadProfile, DailyPlan, PlanTemplate, etc.)
├── enums/           # PlanMode, WorkStyle, DisruptionType, HouseholdDuty
├── providers/       # State management (Plan, Profile, Condition, Disruption)
├── services/        # Business logic (Storage, ConditionCalculator, PlanGenerator)
├── screens/
│   ├── onboarding/  # 5-step onboarding flow
│   ├── dashboard/   # Main app (Today / Records / Settings)
│   └── settings/    # Template management & day assignment
├── constants/       # Thresholds, task catalog
└── utils/           # Date extensions
```

## CI/CD

`main` ブランチへの push で自動実行:
1. `flutter analyze` (静的解析)
2. `flutter test` (テスト)
3. `flutter build apk` (APK ビルド)
4. Firebase App Distribution (internal-testers グループへ配布)

## License

Private project.
