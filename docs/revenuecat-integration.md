# RevenueCat統合ガイド（iOS/SwiftUI）

このプロジェクトはiOS/SwiftUIで開発するため、RevenueCat iOS SDKの統合方法をまとめる。

---

## クイックスタート

### 1. SDKを追加（Swift Package Manager）

XcodeでSPMを使って追加：

**Package URL**: `https://github.com/RevenueCat/purchases-ios`

追加するライブラリ：
- `RevenueCat` - メインSDK
- `RevenueCatUI` - ビルトインPaywall UI（オプションだが推奨）

### 2. SDKを初期化

```swift
import SwiftUI
import RevenueCat

@main
struct MyApp: App {
    init() {
        // デバッグ用にすべてのログを出力
        Purchases.logLevel = .debug

        // APIキーで初期化
        Purchases.configure(
            withAPIKey: "<public_apple_api_key>",
            appUserID: "<app_user_id>"  // nilでも可（自動生成される）
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

> **Note**: `appUserID` を指定しない場合、RevenueCatが自動で匿名IDを生成・管理する。リストア機能を正しく使うには、バックエンドが提供するユニークIDを使用するのが望ましい。

---

## Entitlementの確認

Entitlementは、購入後にユーザーがアンロックするアクセスレベルや機能を表す。広告バナーの表示/非表示やプレミアムアクセスの判定に使う。

```swift
import SwiftUI
import RevenueCat

struct ContentView: View {
    @State private var isSubscribed: Bool = false
    let ENTITLEMENT_ID = "premium"  // RevenueCatダッシュボードで設定したID

    var body: some View {
        VStack {
            if isSubscribed {
                PremiumContent()
            } else {
                Text("This is the free content.")
                // ここでPaywallを表示するなど
            }
        }
        .task {
            await checkEntitlement()
        }
    }

    private func checkEntitlement() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if customerInfo.entitlements[ENTITLEMENT_ID]?.isActive == true {
                self.isSubscribed = true
            } else {
                self.isSubscribed = false
            }
        } catch {
            print("Error fetching customer info: \(error)")
        }
    }
}
```

---

## 購入フローの実装

### 商品を取得して購入

```swift
import RevenueCat

class PurchaseViewModel: ObservableObject {

    func fetchProducts() async -> [StoreProduct] {
        do {
            // 商品IDで取得
            let products = try await Purchases.shared.products([
                "premium_monthly",
                "premium_yearly"
            ])
            return products
        } catch {
            print("Error fetching products: \(error)")
            return []
        }
    }

    func purchase(product: StoreProduct) async {
        do {
            let result = try await Purchases.shared.purchase(product: product)

            // 購入後にEntitlementを確認
            if result.customerInfo.entitlements["premium"]?.isActive == true {
                print("Purchase successful!")
                // プレミアムコンテンツをアンロック
            }
        } catch {
            print("Error purchasing: \(error)")
        }
    }
}
```

> `Purchases.shared.purchase(product:)` を呼ぶと、ネイティブのApp Store購入シートが自動で表示される。レシート処理やStoreKit APIの複雑さを扱う必要なし。

---

## Paywallの実装

### Option 1: PaywallView（最もシンプル）

RevenueCatUIを使うと、ダッシュボードで設定したデザインのPaywallが自動で表示される。

```swift
import SwiftUI
import RevenueCat
import RevenueCatUI

struct ContentView: View {
    @State private var showPaywall = false

    var body: some View {
        Button("Show Paywall") {
            showPaywall = true
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()  // 自動でcurrent offeringを取得して表示
        }
    }
}
```

### Option 2: 条件付き自動表示

特定のEntitlementがない場合に自動でPaywallを表示：

```swift
import SwiftUI
import RevenueCat
import RevenueCatUI

@main
struct MyApp: App {
    // init code...

    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentPaywallIfNeeded(
                    requiredEntitlementIdentifier: "premium",
                    purchaseCompleted: { customerInfo in
                        print("Purchase completed: \(customerInfo.entitlements)")
                    },
                    restoreCompleted: { customerInfo in
                        print("Restore completed: \(customerInfo.entitlements)")
                    }
                )
        }
    }
}
```

### Option 3: Offeringを手動で取得

```swift
import Foundation
import RevenueCat
import SwiftUI

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var offering: Offering?
    @Published var isLoading: Bool = false

    init() {
        Task {
            await fetchOffering()
        }
    }

    func fetchOffering() async {
        self.isLoading = true
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offering = offerings.current
        } catch {
            print("Error fetching offerings: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
}

// 使用例
struct ContentView: View {
    @State private var showPaywall = false
    @StateObject private var paywallViewModel = PaywallViewModel()

    var body: some View {
        VStack {
            Button("Upgrade to Premium") {
                showPaywall = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            if paywallViewModel.isLoading {
                ProgressView()
            } else if let offering = paywallViewModel.offering {
                PaywallView(offering: offering)
            } else {
                Text("Sorry, we couldn't load options.")
            }
        }
    }
}
```

---

## サーバードリブンUI

PaywallはサーバードリブンUIで構築されている。つまり：
- ダッシュボードから**コンテンツとデザインを動的に更新可能**
- **アプリ更新やApp Storeレビューなし**で変更を反映

---

## 利用可能なCodelabs

| Codelab | 内容 | リンク |
|---------|------|--------|
| **iOS In-App Purchases & Paywalls with SwiftUI** | SDK設定、商品取得、購入、Paywall実装 | [Start](https://revenuecat.github.io/codelabs/ios.html) |
| **App Store Integration** | App Store Connect設定、商品作成、S2S通知 | [Start](https://revenuecat.github.io/codelabs/app-store.html) |
| **Boost Your App Revenue** | Paywall最適化、A/Bテスト、Targeting、チャーン削減 | [Start](https://revenuecat.github.io/codelabs/monetization-strategies.html) |

---

## 公式リソース

- [RevenueCat Documentation](https://www.revenuecat.com/docs/)
- [RevenueCat iOS SDK GitHub](https://github.com/RevenueCat/purchases-ios)
- [Blog: iOS In-App Subscription Tutorial with StoreKit 2 and Swift](https://www.revenuecat.com/blog/engineering/ios-in-app-subscription-tutorial-with-storekit-2-and-swift/)
- [Displaying Paywalls with RevenueCatUI](https://www.revenuecat.com/docs/tools/paywalls)
