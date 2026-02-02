# Shipyard提出ガイド

アプリストアのレビューや本番リリース要件を通過する必要はない。重要なのは**審査員がアプリを確実にインストールして評価できること**。

---

## 必須ルール

| ルール | 詳細 |
|--------|------|
| **モバイルアプリのみ** | iOS、Android、またはクロスプラットフォーム（Web/デスクトップは不可） |
| **期間内に開発** | ハッカソン期間中に開始・完了したプロジェクトのみ |
| **1人1ブリーフ** | 1つのブリーフに対して1つのアプリのみ提出可能 |
| **RevenueCat統合必須** | サブスクリプションまたはアプリ内課金を実装 |
| **テスト配信必須** | TestFlight（iOS）またはGoogle Play Testing Track（Android） |
| **IP保持** | 開発者がIPを完全に保持 |
| **インフルエンサーの名前/肖像** | 使用した場合、公開前に削除必須（合意がない限り） |

---

## 使用可能な技術

- **言語/フレームワーク**: Swift、Kotlin、Flutter、React Native など何でもOK
- **ツール**: Cursor、Xcode、Claude、Vibecode、Rork など何でもOK
- **条件**: Apple App Store または Google Play Store にアップロードできるモバイルアプリを生成すること
- **Capacitor**: WebアプリをネイティブモバイルアプリにするのはOK

---

## RevenueCat統合要件

| 要件 | 詳細 |
|------|------|
| RevenueCat SDK | インストール済みであること |
| アプリ内課金設定 | ターゲットプラットフォーム向けに設定済み |
| **テストモードで購入可能** | 実際にテスト購入ができること |

> **注意**: Test Store設定だけでは**統合済みとはみなされない**。Apple Developer AccountまたはGoogle Play Developer Accountが必要。

---

## iOS: TestFlight設定手順

### 1. ビルドをアップロード

Xcodeを使ってApp Store Connectにビルドをアップロードする。

### 2. External Testingを有効化

App Store Connectの**TestFlightタブ**でExternal Testingを有効にする。

### 3. Public Linkを作成

**誰でもリンクからインストールできる**Public TestFlight Linkを作成する（手動でテスターを追加する必要がない）。

### 4. 確認事項

- ビルドが安定していて正しく起動すること
- コア機能にアクセスできること
- サブスク/アプリ内課金が**テストモードで購入可能**であること

### 5. 提出

Public TestFlightリンクをDevpost提出に含める。

---

## Android: Google Play Testing Track設定手順

3つのオプションがある。いずれも `shipyard-android@revenuecat.com` を**テスターとして追加**する必要がある。

### Option 1: Internal Testing

1. Google Play Consoleにアプリをアップロード
2. Internal testing trackを作成
3. `shipyard-android@revenuecat.com` をテスターメールとして追加
4. ビルドがInternal testing承認後、インストールと機能確認

### Option 2: Closed Testing

1. Closed testing trackにビルドをアップロード
2. `shipyard-android@revenuecat.com` をテスターリストに追加（直接またはGoogle Group経由）
3. 提出前にアクセス権が付与されていることを確認

### Option 3: Public Testing

1. Public testing trackにアップロード
2. 承認なしで誰でもインストール可能
3. Public testingバージョンへのリンクをDevpost提出に含める

---

## 公開は任意

| 項目 | 詳細 |
|------|------|
| App Store/Google Play公開 | ハッカソン中・後に公開してOK |
| 審査への影響 | 公開しても失格にならない |
| 審査への優遇 | 公開しても審査に有利にならない |

> 公開を待つ必要はないし、公開しても問題ない。

---

## 審査プロセス

### デモ動画が主な審査対象

提出数が多いため、**すべてのアプリがインストール・テストされるわけではない**。**デモ動画**がすべてのアプリを審査する主な方法。ショートリストに残ったアプリはより詳細に確認される。

### 受賞作品の検証

**すべての受賞作品**は以下を検証される：
- インストール可能かどうか
- RevenueCat SDK統合が正しいか
- サブスク/アプリ内課金が説明通りに実装されているか

> **注意**: 受賞作品がインストールできない、またはRevenueCat統合が動作しない場合、**失格となり賞が再割り当てされる可能性がある**。

### 確認チェックリスト

- [ ] 提出したビルドがインストール可能
- [ ] アプリが安定している
- [ ] デモ動画の内容と実際のアプリが一致している

---

## 提出物チェックリスト

1. **アプリアクセス** - TestFlight Public Link または Google Play Testing Track
2. **デモ動画（2〜3分）** - 主要機能のウォークスルー、オンボーディングから収益化までのフロー
3. **企画書（1〜2ページ）** - 課題設定、ソリューション概要、収益化戦略、ロードマップ
4. **技術ドキュメント** - アーキテクチャ概要、RevenueCat統合の詳細
5. **開発者プロフィール** - 経歴、ポートフォリオ、参加動機

---

## 困ったら

[Shipyard Discord](https://discord.com/invite/3aV6EUCYqR) で質問する。
