# MVP要件定義

## コンセプト

**「見たレシピ」を「実際の夕食」に変える**

レシピURLから買い物リストを自動生成し、さらに手元の材料や好みに合わせて食材・調理工程をカスタマイズできるアプリ。

---

## 背景・課題

Eitan Bernathのブリーフより：
> 「最近みんな、特に料理本やソーシャルメディアでレシピを大量に保存してるけど、『見たもの』から『実際に作る』までのハードルが高い」

### 解決したい課題
1. レシピを見つけても、買い物リストを作るのが面倒
2. レシピ通りの材料が手元にない／買いに行けない
3. 家族の好み・アレルギーに合わせたアレンジが難しい

---

## MVPスコープ

### 含める

| 機能 | 詳細 |
|------|------|
| レシピURL取り込み | Webレシピサイトからの抽出 |
| 買い物リスト生成 | 材料リストをカテゴリ分けして表示 |
| 食材の置き換え | 「鶏肉→豚肉」「人参→かぼちゃ」など |
| 調理工程の置き換え | 「揚げる→オーブンで焼く」など |
| サブスクリプション課金 | RevenueCat統合 |

### 含めない（MVP後）

| 機能 | 理由 |
|------|------|
| 動画からの抽出（TikTok等） | 技術的難易度が高い |
| 分量調整（2人分→4人分） | スコープを絞る |
| レシピの永続化・一覧表示 | スコープを絞る |
| 買い物リストのチェックオフ | 永続化とセットで対応 |

---

## コア機能詳細

### 1. レシピ取り込み

- URLを入力すると、レシピ情報を抽出
- 対応ソース（MVP）:
  - Webレシピサイト（Cookpad、クラシル、Delish Kitchen等）
- 抽出する情報:
  - 料理名
  - 材料リスト（分量含む）
  - 調理工程

**技術アプローチ**: LLM API（Claude/OpenAI）でURLの内容を解析・構造化

### 2. 買い物リスト生成

- 抽出した材料から買い物リストを自動生成
- カテゴリ分け（野菜、肉、調味料など）
- チェックオフ機能はMVP後

### 3. 置き換え機能（差別化ポイント）

**UI**:
- 食材リストの各項目がタップ可能
- 調理ステップの各項目がタップ可能
- タップすると入力欄が現れ、質問や変更指示を書ける

**ユースケース例**:
- 「鶏肉を豚肉に変えて」（冷蔵庫の在庫）
- 「人参をかぼちゃに変えて」（子供の好み）
- 「牛乳をオーツミルクに変えて」（アレルギー・好み）
- 「揚げるのが面倒だからオーブンで焼く方法に変えて」（調理工程の簡略化）

**結果**:
- 買い物リストが自動更新
- 調理工程も自動調整

---

## マネタイズ

### モデル: サブスクリプション（機能制限あり）

| プラン | 内容 |
|--------|------|
| 無料 | URL→買い物リスト生成のみ |
| 有料（サブスク） | 置き換え機能が使える |

**RevenueCat統合必須**（コンテストの要件）

---

## データフロー（MVP）

```
[ユーザー]
    |
    | URL入力
    v
[アプリ]
    |
    | URLからHTML取得
    v
[LLM API]
    |
    | レシピ構造化（料理名、材料、工程）
    v
[アプリ]
    |
    | 表示
    v
[ユーザー]
    |
    | 食材/工程をタップして置き換え指示（有料機能）
    v
[LLM API]
    |
    | 置き換え後のレシピ生成
    v
[アプリ]
    |
    | 買い物リスト表示
    v
[ユーザー]
```

※ アプリを閉じるとデータは消える（使い捨て）

---

## 技術構成

| 項目 | 選定 | 備考 |
|------|------|------|
| プラットフォーム | iOS（SwiftUI） | |
| 最小サポートバージョン | iOS 26+ | Xcode 26 / Swift 6 |
| バックエンド | なし（スタンドアロン） | |
| LLM API | OpenAI | Structured Outputsが強力でスキーマ準拠を保証できる |
| OpenAI SDK | MacPaw/OpenAI | Swift製のOpenAIクライアントライブラリ |
| モデル・APIキー管理 | Firebase Remote Config | アプリ更新なしでモデル変更可能 |
| HTML取得 | URLSession | 直接取得。JSレンダリング不要なサイトを対象 |
| 課金 | RevenueCat SDK | |
| APIキー管理 | Firebase Remote Config | モデルと一緒に外部から注入 |
| アーキテクチャ | 既存プロジェクトから流用 | |
| ローカルデータ | なし（MVP） | 使い捨て |
| エラーハンドリング | シンプルにアラート表示 | 失敗時はアラート＋リトライボタン |
| 対応言語（レシピ） | 制限なし | LLMが解釈するので言語非依存 |
| アプリUI言語 | 日本語・英語 | 既存プロジェクトのローカライズ基盤を流用 |
| テスト | ユニット・UI・スナップショット | 既存プロジェクトのテスト基盤を流用 |

### 重点テスト対象レシピサイト（US市場向け）

| サイト | 特徴 | curl取得 | 備考 |
|--------|------|----------|------|
| Allrecipes | 最大手のUGCレシピサイト。ユーザー投稿・評価が活発 | ✅ OK | JSON-LD `recipeIngredient` あり |
| Food Network | テレビ番組連動の権威あるサイト。Eitanも出演歴あり | ❌ NG | ボット対策でAccess Denied |
| Epicurious | Condé Nast運営。キュレーション型 | ✅ OK | JSON-LD `@type: Recipe` あり |
| Delish | Hearst運営。トレンド系レシピ、Eitanも寄稿歴あり | ✅ OK | JSON-LD `recipeIngredient` あり |
| Budget Bytes | 節約志向。ステップバイステップの写真が充実 | ✅ OK | JSON-LD完備（材料+工程）|

**注**: Food Networkはボット対策（Akamai）が厳しく、curlでのHTML取得が不可。Safari/iPhone/Chrome等の様々なUser-Agentを試したが、すべて「Access Denied」。TLSフィンガープリントやJavaScript challengeによる検出と思われる。URLSessionでも同様の結果が予想されるため、MVP対象外とする。

#### 検証済みレシピURL

| サイト | テストURL |
|--------|-----------|
| Allrecipes | https://www.allrecipes.com/baked-caesar-chicken-recipe-7499125 |
| Epicurious | https://www.epicurious.com/recipes/food/views/quick-chicken-piccata |
| Delish | https://www.delish.com/cooking/recipe-ideas/a24489879/beef-and-broccoli-recipe/ |
| Budget Bytes | https://www.budgetbytes.com/chicken-stir-fry/ |

### 重点テスト対象レシピサイト（日本市場向け）

| サイト | 特徴 | curl取得 | 備考 |
|--------|------|----------|------|
| Cookpad | 最大手のUGCレシピサイト。日本発 | ✅ OK | JSON-LD `recipeIngredient` あり |
| クラシル | 動画レシピの先駆け。若年層に人気 | ✅ OK | JSON形式で`ingredients`配列あり |
| DELISH KITCHEN | 動画レシピ。管理栄養士監修 | ✅ OK | 構造化データなし、HTML+LLM抽出で対応 |
| Orange Page | 老舗料理雑誌のWebサイト | ✅ OK | JSON-LD `recipeIngredient` あり |
| キッコーマン | 調味料メーカーの公式レシピ | ✅ OK | JSON-LD `recipeIngredient` あり |

#### 検証済みレシピURL（日本）

| サイト | テストURL |
|--------|-----------|
| Cookpad | https://cookpad.com/jp/recipes/25370127 |
| クラシル | https://www.kurashiru.com/recipes/2a9f8d3a-2404-4da0-8574-9f890017b6a4 |
| DELISH KITCHEN | https://delishkitchen.tv/recipes/140622220790186498 |
| Orange Page | https://www.orangepage.net/recipes/304275 |
| キッコーマン | https://www.kikkoman.co.jp/homecook/search/recipe/00006656/ |

---

## 対象ユーザー

- 料理初心者〜中級者
- SNSでレシピを保存するが、実際に作るまでに至らない人
- 忙しくて買い物リスト作成に時間をかけたくない人
- 家族の好みや制限に合わせてアレンジしたい人

---

## Eitanに刺さるポイント

1. **「見る」→「作る」のハードルを下げる** - 彼のブリーフの核心
2. **手元にあるもので世界の料理を作る** - 彼の原体験（教師の両親、食を通じた旅）
3. **料理を楽しくする** - 彼の料理哲学
4. **アクセシビリティ** - 誰でも簡単に使える

