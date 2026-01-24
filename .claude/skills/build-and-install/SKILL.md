---
name: build-and-install
description: アプリをビルドし、SmokeTest1とSmokeTest2の2つのシミュレータにインストールするスキル。使用シーン：(1)「アプリをビルドしてインストールして」などのリクエスト (2) テスト前の環境準備 (3) 新しいビルドをシミュレータに展開する必要がある場合
user-invocable: true
---

# Build and Install

アプリをビルドし、指定された2つのシミュレータ（SmokeTest1、SmokeTest2）にインストールするスキル。

## 概要

このスキルは以下の処理を自動実行する:

1. アプリのビルド（Okumukaスキーム）
2. SmokeTest1シミュレータの起動とアプリインストール
3. SmokeTest2シミュレータの起動とアプリインストール

## 前提条件

- Xcodeプロジェクト: `Okumuka.xcodeproj`
- スキーム: `Okumuka`
- バンドルID: `app.hiragram.Okumuka`
- ターゲットシミュレータ:
  - `SmokeTest1`
  - `SmokeTest2`

## 実行手順

### 1. シミュレータの確認と準備

```
1. list_simulatorsでSmokeTest1とSmokeTest2を検索
2. 各シミュレータのUDIDを取得
3. 必要に応じてboot_simulatorで起動
```

### 2. アプリのビルド

xcodebuildコマンドでアプリをビルド:

```bash
xcodebuild build \
  -project Okumuka.xcodeproj \
  -scheme Okumuka \
  -destination 'platform=iOS Simulator,name=SmokeTest1' \
  -derivedDataPath .build
```

**重要ポイント**:
- `-derivedDataPath .build` を指定してビルド成果物の場所を固定
- ビルド完了後、.appファイルのパスを特定する必要がある

### 3. .appファイルのパス特定

ビルド成果物から.appファイルを探す:

```bash
find .build -name "Okumuka.app" -type d
```

通常、以下のようなパスになる:
```
.build/Build/Products/Debug-iphonesimulator/Okumuka.app
```

### 4. シミュレータへのインストール

各シミュレータに対してxcrun simctlでアプリをインストール:

```bash
# SmokeTest1へインストール
xcrun simctl install <SmokeTest1_UDID> .build/Build/Products/Debug-iphonesimulator/Okumuka.app

# SmokeTest2へインストール
xcrun simctl install <SmokeTest2_UDID> .build/Build/Products/Debug-iphonesimulator/Okumuka.app
```

## 実装例

### シミュレータ検索と起動

```python
# list_simulatorsでシミュレータ一覧を取得
simulators = list_simulators()

# SmokeTest1とSmokeTest2を検索
smoketest1 = next((s for s in simulators if s['name'] == 'SmokeTest1'), None)
smoketest2 = next((s for s in simulators if s['name'] == 'SmokeTest2'), None)

# 起動が必要な場合は起動
if smoketest1['state'] != 'Booted':
    boot_simulator(smoketest1['udid'])
if smoketest2['state'] != 'Booted':
    boot_simulator(smoketest2['udid'])
```

### ビルド実行

```bash
xcodebuild build \
  -project Okumuka.xcodeproj \
  -scheme Okumuka \
  -destination 'platform=iOS Simulator,name=SmokeTest1' \
  -derivedDataPath .build
```

### インストール実行

```bash
# .appパスを特定
APP_PATH=$(find .build -name "Okumuka.app" -type d | head -1)

# 各シミュレータにインストール
xcrun simctl install <UDID1> "$APP_PATH"
xcrun simctl install <UDID2> "$APP_PATH"
```

## 結果報告

処理完了後、以下の形式で報告:

```
## ビルド＆インストール結果

✅ ビルド完了: Okumuka.app
✅ SmokeTest1へインストール完了
✅ SmokeTest2へインストール完了

アプリパス: .build/Build/Products/Debug-iphonesimulator/Okumuka.app
```

## エラーハンドリング

### シミュレータが見つからない

```
SmokeTest1またはSmokeTest2が見つからない場合:
- list_simulatorsの結果を確認
- シミュレータ名が正確か確認
- ユーザーに報告
```

### ビルド失敗

```
ビルドエラーが発生した場合:
- エラーメッセージを確認
- コンパイルエラー、依存関係の問題などを特定
- ユーザーに詳細を報告
```

### インストール失敗

```
インストールエラーが発生した場合:
- シミュレータが起動しているか確認
- .appファイルが存在するか確認
- xcrun simctlのエラーメッセージを確認
```

## 使用するツール

| ツール | 用途 |
|-------|------|
| `mcp__plugin_ios-team_iossim__list_simulators` | シミュレータ一覧取得 |
| `mcp__plugin_ios-team_iossim__boot_simulator` | シミュレータ起動 |
| `Bash(xcodebuild:*)` | アプリビルド |
| `Bash(xcrun simctl:*)` | アプリインストール |
| `Bash(find:*)` | .appファイル検索 |

## 注意事項

1. **derivedDataPathの指定**: ビルド成果物の場所を固定するため、必ず`-derivedDataPath .build`を指定する
2. **シミュレータ起動**: インストール前にシミュレータが起動している必要がある
3. **既存アプリの扱い**: 同じバンドルIDのアプリが既にインストールされている場合、上書きされる
4. **ビルド設定**: Debug構成でビルドされる（リリース版が必要な場合は`-configuration Release`を追加）

## 最適化のヒント

- 2つのシミュレータへのインストールは並列実行可能
- ビルドは1回のみで、同じ.appを両方のシミュレータで使用
- シミュレータが既に起動している場合は起動をスキップ
