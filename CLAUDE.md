# CLAUDE.md

このファイルはClaude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## プロジェクト概要

レシピ分析・買い物リストアプリ

## 要件定義・背景・MVPなどのドキュメント

- ハッカソン概要: @docs/hackathon.md
- ハッカソンの題材となる要件: @docs/briefs.md
- このプロジェクトで作るアプリの要件・MVP: @docs/mvp.md

## [重要]このプロジェクトの背景

- 上述のハッカソンに参加するためのプロジェクトである。
- iOSアプリのXcodeプロジェクトについて、Okumukaという既存のアプリのプロジェクト構造を流用する。
- Okumukaの完全なXcodeプロジェクトをまずこのリポジトリに持ち込んで、これをベースに新しい画面を追加したりこちらのプロジェクトで不要な実装を削ったりしていく。

以下、OkumukaのCLAUDE.mdをそのままコピペしたもの。

---

## 実装ルール（必須 - 絶対に無視しないこと）

**⚠️ 重要: このプロジェクトではt-wada styleのTDDを必ず実践すること。TDDを省略して実装を先に書くことは禁止。**

### TDDの手順（RED-GREEN-REFACTOR）

機能追加・バグ修正を行う際は、以下の順序を厳守すること：

#### 1. RED（テストが失敗することを確認）
1. テストコードを書く
2. プロダクションコードにダミー実装（`fatalError()` や固定値を返す等）を追加
3. テストを実行し、**ビルドが通り、テストがFAILすることを確認**
4. ユーザーに「REDを確認しました」と報告

**注意**: ビルドエラーはREDではない。テストが実行されてFAILすることがRED。

#### 2. GREEN（テストを通す）
1. ダミー実装を本実装に書き換える
2. テストを実行し、PASSすることを確認
3. ユーザーに「GREENを確認しました」と報告

#### 3. REFACTOR（必要に応じてリファクタリング）
1. コードを整理（重複排除、命名改善など）
2. テストが引き続きPASSすることを確認

### TDDを適用する場面
- Reducerのロジック追加・変更
- モデルの新規作成・変更
- ユーティリティ関数の追加
- ビジネスロジックの追加・修正

### TDDを適用しない場面
- 純粋なUIの変更（スナップショットテストで対応）
- 設定ファイルの変更
- ドキュメントの更新

## ビルドとテスト

- 常に `xcodebuild` を使用する（`swift build` / `swift test` は使用しない）
- pbxproj mcpを使ってターゲットやスキームを都度確認すること

## プロジェクト構成

## アーキテクチャ: Reduxパターン

アプリはReduxに基づくアーキテクチャを採用:

```
AppCore/Store/
├── AppState.swift          # ルート状態（Single Source of Truth）
├── AppAction.swift         # 全アクションenum
├── AppReducer.swift        # ルートReducer
├── AppStore.swift          # Store（状態保持 + dispatch + 副作用）
├── ScheduleState.swift     # 機能別の状態
├── ScheduleAction.swift    # 機能別のアクション
├── ScheduleReducer.swift   # 純粋関数（テストの主対象）
├── Home{State,Action,Reducer}.swift
├── Assignment{State,Action,Reducer}.swift
├── MyAssignments{State,Action,Reducer}.swift
├── Sharing{State,Action,Reducer}.swift
└── Auth{State,Action,Reducer}.swift
```

**設計原則:**
- 状態は読み取り専用、変更はActionを介してのみ
- Reducerは純粋関数（副作用なし）- テストが容易
- 副作用（Supabase、ネットワーク）は `AppStore.handleSideEffects()` で処理
- Viewはパラメータを受け取り、`@State`を持たない - ContainerViewパターンを使用

**Containerパターン:**
```swift
// ContainerViewがStoreとViewを接続
ScheduleContainerView(store: store)  // Store ↔ View の橋渡し
WeeklyScheduleView(entries: ..., onTap: ...)  // 純粋なView、パラメータのみ
```

## データ層

- **Supabase** - PostgreSQLデータベースでデータを永続化
- **OTP認証** - メールアドレスによるワンタイムパスワード認証
- **FCM（Firebase Cloud Messaging）** - プッシュ通知による変更通知
- **RLS（Row Level Security）** - データベースレベルでのアクセス制御

**主要モデル:**
- `User` - ユーザープロフィール（profiles テーブル）
- `DayScheduleEntry` - 1日分の送り/迎えステータス（schedule_entries テーブル）
- `DayAssignment` - 担当割り当て（day_assignments テーブル）
- `UserGroup` / `UserGroupMembership` - 家族共有用（user_groups / group_memberships テーブル）
- `WeatherLocation` - 天気地点（weather_locations テーブル）

## Supabase統合の注意点

### ローカル開発環境

**⚠️ 重要: Supabaseのローカルインスタンスは`npx supabase`コマンドを直接使わず、必ず専用スクリプトを使用すること。**

```bash
./scripts/supabase-local start   # 起動
./scripts/supabase-local stop    # 停止
./scripts/supabase-local reset   # DBリセット（マイグレーション再適用）
./scripts/supabase-local status  # 状態確認
./scripts/supabase-local studio  # Supabase Studioを開く
```

**理由**: git worktreeを使用している場合、`npx supabase`コマンドはgitルートを辿ってメインリポジトリの`supabase/`ディレクトリを参照してしまう。専用スクリプトは`--workdir`オプションで現在のworktreeを明示的に指定するため、worktree内のマイグレーションが正しく適用される。

### RLSによる権限制御

CloudKitと異なり、SupabaseではRow Level Security（RLS）でデータベースレベルの権限制御を行う。
Zone管理やオーナー/参加者の区別は不要で、ユーザーは自身が所属するグループのデータにのみアクセス可能。

### 招待コードによるグループ参加フロー

1. オーナーが招待コードを生成
2. 参加者が招待コードを入力
3. `approved` 状態のメンバーシップを直接作成
4. 参加者は即座にグループのデータにアクセス可能

## テスト

テストはSwift Testingフレームワークを使用（XCTestではない）:

```swift
@Suite
struct ScheduleReducerTests {
    @Test
    func reduce_updateEntry_updatesDropOffStatus() {
        var state = ScheduleState()
        // ... セットアップ ...
        ScheduleReducer.reduce(state: &state, action: .updateEntry(...))
        #expect(state.weekEntries[0].dropOffStatus == .ok)
    }
}
```

モックは `AppCoreTests/Mocks/` にあり、プロトコルベースの依存性注入を使用。

## スナップショットテスト（重要）

**UIに関わる変更をした場合、必ずスナップショットテストのリファレンス画像を更新すること。**

本プロジェクトではPrefireを使用してSwiftUIプレビューからスナップショットテストを自動生成している。内部的にはpointfreeco/swift-snapshot-testingを使用。

### リファレンス画像の更新手順

**⚠️ 重要: リファレンス画像を更新する際は、必ず専用スクリプトを使用すること。`rm`コマンドで直接削除してはならない。**

```bash
./scripts/regenerate-snapshot-reference
```

このスクリプトは以下を自動で行う:
1. リファレンス画像ディレクトリを削除
2. スナップショットテストを実行（画像を再生成）
3. スナップショットテストを再実行（成功を検証）

スクリプト実行後、生成されたリファレンス画像をコミットに含めること。

### 注意点

- スナップショットテストはシミュレータの機種・OSバージョンに依存する
- UIを変更したのにリファレンス画像を更新しないと、CIでテストが失敗する
- リファレンス画像は `AppCoreTests/__Snapshots__/PreviewTests/` に保存される

## 重要な注意事項

- AppCore.frameworkの `DYLIB_INSTALL_NAME_BASE` は `@rpath` に設定必須（埋め込みフレームワークに必要）
- iOS 26.2が必要（`@Observable`マクロを使用）
- UIは日本語（日付フォーマットにja_JPロケール使用）

## スクリーンショット分析のルール

iOSシミュレータのスクリーンショットを確認・分析する必要がある場合、**メインセッションでReadツールを使って画像を直接読み込まないこと**。

代わりに `ios-screenshot-analyzer` サブエージェントを使用する。

**理由**: 画像データはコンテキストを大きく圧迫する。サブエージェントに委譲することで、メインセッションには分析結果のテキストのみが返り、コンテキストを効率的に使える。

**使い方**:
```
# シミュレータIDを渡す場合
Task(ios-screenshot-analyzer): "シミュレータID XXXXのスクリーンショットを取得し、〇〇を確認してください"

# 既存のスクリーンショットパスを渡す場合
Task(ios-screenshot-analyzer): "スクリーンショット /tmp/screenshot.png を分析し、〇〇を確認してください"
```
