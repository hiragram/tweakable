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

---

## Xcode 26 型安全ローカライズ

このプロジェクトではXcode 26の新機能「String Catalog Symbol Generation」を使用している。

### 概要

String Catalog（`.xcstrings`）から `LocalizedStringResource` の static property が自動生成され、文字列リテラルの代わりに型安全なシンボルを使用できる。

### Before / After

```swift
// ❌ Before: 文字列リテラル（タイポしてもコンパイルエラーにならない）
Text("recipe_section_ingredients", bundle: .app)
String(localized: "recipe_button_retry", bundle: .app)

// ✅ After: 型安全シンボル（存在しないキーはコンパイルエラー）
Text(.recipeSectionIngredients)
String(localized: .recipeButtonRetry)
```

### 有効化の条件

シンボル生成には以下が必要：

1. **ビルド設定**: Xcode 26以降ではString Catalog Symbol Generationがデフォルトで有効
2. **extractionState**: String Catalog内の各エントリが `"extractionState": "manual"` である必要がある

⚠️ **重要**: `extractionState` が `"extracted_with_value"` のままだとシンボルが生成されない。新しいキーを追加した場合は、String Catalog JSONを編集して `"manual"` に変更すること。

### シンボル命名規則

String Catalogのキー名がキャメルケースに変換される：

| String Catalog キー | 生成されるシンボル |
|---------------------|-------------------|
| `recipe_section_ingredients` | `.recipeSectionIngredients` |
| `common_ok` | `.commonOk` |
| `shopping_lists_item_count` | `.shoppingListsItemCount` |

### プレースホルダー付き文字列（重要）

`%@` や `%d` などのプレースホルダーを含む文字列は、**引数を受け取る関数**として生成される。

```swift
// String Catalog:
// "recipe_error_html_fetch_failed" = "Failed to fetch recipe: %@"

// ❌ 間違い: 引数なしで呼ぶとコンパイルエラー
String(localized: .recipeErrorHtmlFetchFailed)

// ✅ 正解: 引数を渡す
String(localized: .recipeErrorHtmlFetchFailed(detail))
```

String Catalogで該当キーの `value` を確認し、プレースホルダーがあるかどうかを確認すること。

### 生成されるシンボルのスコープ

- 生成されるシンボルは `internal` スコープ
- AppCoreフレームワーク内のViewやStoreからは使用可能
- 外部モジュールからは直接アクセス不可（必要なら公開APIを別途作る）

### レガシーViewとの共存

- `*_Okumuka` サフィックス付きのレガシーViewは従来の `Text("key", bundle: .app)` パターンを維持
- 新規View（サフィックスなし）では型安全シンボルを使用すること
- `Bundle+App.swift` はレガシーView用に残してある

### トラブルシューティング

#### シンボルが見つからない場合

1. **ビルドを実行**: シンボルはビルド時に生成されるため、一度ビルドしないと補完に出てこない
2. **extractionState確認**: String Catalog JSONで `"extractionState": "manual"` になっているか確認
3. **キー名確認**: キー名に使えない文字（スペース、特殊文字など）が含まれていないか確認

#### コンパイルエラー「expects argument of type 'String'」

プレースホルダー付き文字列なのに引数を渡していない。String Catalogで `value` を確認し、適切な引数を渡すこと。

### 新しいローカライズキーを追加する手順

1. `AppCore/Localizable.xcstrings` に新しいキーを追加
2. JSONエディタで `"extractionState": "manual"` を設定
3. AppCoreをビルド（シンボルが生成される）
4. View/Storeから `Text(.newKeyName)` や `String(localized: .newKeyName)` で使用
