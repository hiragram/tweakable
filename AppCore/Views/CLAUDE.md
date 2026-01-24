# Views ディレクトリのルール

## accessibilityIdentifier 必須

操作可能なUIパーツには必ず `.accessibilityIdentifier()` を追加すること。

### 対象となる要素

- Button
- TextField
- Toggle
- Picker
- NavigationLink
- List内のタップ可能な行
- Map（タップ操作がある場合）
- その他ユーザーが操作可能な要素

### 命名規則

`画面名_要素種別_用途` の形式でキャメルケースを使用する。

```swift
// 例
.accessibilityIdentifier("home_button_settings")
.accessibilityIdentifier("welcome_textField_userName")
.accessibilityIdentifier("settings_button_inviteMember")
```

### 動的要素の場合

リストやForEach内の要素には、一意に識別できるようインデックスやIDを付与する。

```swift
// インデックスを使用
.accessibilityIdentifier("weeklySchedule_button_dropOff_day\(index)")

// IDを使用
.accessibilityIdentifier("settings_button_location_\(location.id.uuidString)")

// 参加者IDを使用
.accessibilityIdentifier("joinRequestList_button_approve_\(request.participantID)")
```

### 対象外

以下の要素はaccessibilityIdentifierは不要:

- 表示専用のText、Image
- 装飾的な要素（背景、区切り線など）
- タップハンドラを持たないカード・コンテナ
- ProgressView、LoadingIndicatorなどの状態表示
