# UIScripts

Claudeが`run_ui_script`ツールを使ってアプリの動作確認・QAを行うためのUI操作スクリプト集です。

## ディレクトリ構成

```
UIScripts/
├── config.json       # 共通設定（bundleId等）
├── flows/            # 操作フロー（複数ステップの一連の操作）
├── actions/          # 単体アクション（再利用可能な小さな操作）
└── qa/               # QAシナリオ（検証付きの操作）
```

## 使い方

### 1. 基本的な使い方

各JSONファイルには`actions`配列が含まれており、これを`mcp__plugin_ios-team_iossim__run_ui_script`ツールに渡すことでUI操作を実行できます。

```
bundleId: app.hiragram.Okumuka
actions: [JSONファイル内のactions配列]
```

### 2. フロー（flows/）

複数ステップの一連の操作をまとめたもの:

| ファイル | 説明 | 前提条件 |
|---------|------|---------|
| `create-group.json` | 新規グループ作成 | NoGroupView表示状態 |
| `schedule-input.json` | スケジュール入力 | ホーム画面表示状態 |
| `add-weather-location.json` | 天気地点追加 | ホーム画面表示状態 |
| `invite-member.json` | メンバー招待 | ホーム画面（オーナー） |

### 3. 単体アクション（actions/）

再利用可能な小さな操作:

| ファイル | 内容 |
|---------|------|
| `navigation.json` | 画面遷移（設定を開く、グループ切り替え等） |
| `schedule.json` | スケジュール操作（ステータス変更等） |
| `settings.json` | 設定操作（曜日設定、メンバー管理等） |

## JSON形式

### アクションタイプ

| タイプ | 説明 | パラメータ |
|-------|------|-----------|
| `tap` | タップ | target |
| `doubleTap` | ダブルタップ | target |
| `typeText` | テキスト入力 | target, text |
| `swipe` | スワイプ | target, direction |
| `longPress` | 長押し | target, duration |
| `waitForElement` | 要素待機 | target, timeout |
| `assertExists` | 存在確認 | target |
| `getElementValue` | 値取得 | target |

### target指定方法

```json
// accessibilityIdentifierで指定（推奨）
{ "type": "identifier", "value": "home_button_settings" }

// ラベルで指定
{ "type": "label", "value": "設定" }

// 座標で指定（非推奨）
{ "type": "coordinate", "value": [100, 200] }
```

## accessibility identifier一覧

### ホーム画面
- `home_button_enterSchedule` - 予定入力ボタン
- `home_button_settings` - 設定ボタン
- `home_menu_groupSelector` - グループセレクタ
- `home_menu_group_{uuid}` - グループ選択肢
- `home_menu_createGroup` - 新グループ作成
- `home_button_addWeatherLocation` - 天気地点追加
- `home_button_decideAssignee` - 担当者割り当て

### グループ作成
- `noGroup_button_createGroup` - グループ作成ボタン
- `createGroup_textField_groupName` - グループ名入力
- `createGroup_button_clearGroupName` - 名前クリア
- `createGroup_button_create` - 作成ボタン
- `createGroup_button_cancel` - キャンセル

### スケジュール入力
- `weeklySchedule_button_dropOff_day{0-6}` - 送りボタン（日別）
- `weeklySchedule_button_pickUp_day{0-6}` - 迎えボタン（日別）
- `weeklySchedule_button_submit` - 提出ボタン
- `weeklySchedule_button_errorOk` - エラーOK

### 設定画面
- `settings_button_done` - 完了
- `settings_button_joinRequests` - 参加リクエスト
- `settings_button_inviteMember` - メンバー招待
- `settings_button_weekdaySettings` - 曜日設定
- `settings_button_memberList` - メンバー一覧
- `settings_button_location_{uuid}` - 天気地点
- `settings_button_addLocation` - 地点追加
- `settings_button_about` - アプリ情報

### 天気地点編集
- `weatherLocationEdit_button_cancel` - キャンセル
- `weatherLocationEdit_button_save` - 保存
- `weatherLocationEdit_map_selector` - マップ
- `weatherLocationEdit_textField_label` - ラベル入力
- `weatherLocationEdit_button_clearLabel` - ラベルクリア
- `weatherLocationEdit_button_delete` - 削除

### 招待関連
- `inviteMember_button_close` - 閉じる
- `inviteMember_button_copyUrl` - URLコピー
- `inviteMember_button_share` - シェア

### 曜日設定
- `weekdaySettings_button_done` - 完了
- `weekdaySettings_toggle_{identifier}` - 各曜日トグル
