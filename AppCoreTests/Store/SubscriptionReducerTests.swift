import Testing
import Foundation
@testable import AppCore

@Suite
struct SubscriptionReducerTests {

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = SubscriptionState()

        #expect(state.isPremium == false)
        #expect(state.isLoading == false)
        #expect(state.isPurchasing == false)
        #expect(state.isRestoring == false)
        #expect(state.errorMessage == nil)
        #expect(state.availablePackages.isEmpty)
        #expect(state.showsPaywall == false)
    }

    // MARK: - Load Subscription Status Tests

    @Test
    func reduce_loadSubscriptionStatus_setsLoadingState() {
        var state = SubscriptionState()

        SubscriptionReducer.reduce(state: &state, action: .loadSubscriptionStatus)

        #expect(state.isLoading == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_subscriptionStatusLoaded_setsIsPremiumAndClearsLoading() {
        var state = SubscriptionState()
        state.isLoading = true

        SubscriptionReducer.reduce(state: &state, action: .subscriptionStatusLoaded(isPremium: true))

        #expect(state.isPremium == true)
        #expect(state.isLoading == false)
    }

    @Test
    func reduce_subscriptionStatusLoaded_whenNotPremium_setsIsPremiumFalse() {
        var state = SubscriptionState()
        state.isLoading = true
        state.isPremium = true // 既にプレミアムだった場合

        SubscriptionReducer.reduce(state: &state, action: .subscriptionStatusLoaded(isPremium: false))

        #expect(state.isPremium == false)
        #expect(state.isLoading == false)
    }

    @Test
    func reduce_subscriptionStatusLoadFailed_setsErrorAndClearsLoading() {
        var state = SubscriptionState()
        state.isLoading = true

        SubscriptionReducer.reduce(state: &state, action: .subscriptionStatusLoadFailed("ネットワークエラー"))

        #expect(state.errorMessage == "ネットワークエラー")
        #expect(state.isLoading == false)
    }

    // MARK: - Paywall Tests

    @Test
    func reduce_showPaywall_setsShowsPaywallTrue() {
        var state = SubscriptionState()

        SubscriptionReducer.reduce(state: &state, action: .showPaywall)

        #expect(state.showsPaywall == true)
    }

    @Test
    func reduce_hidePaywall_setsShowsPaywallFalse() {
        var state = SubscriptionState()
        state.showsPaywall = true

        SubscriptionReducer.reduce(state: &state, action: .hidePaywall)

        #expect(state.showsPaywall == false)
    }

    // MARK: - Load Packages Tests

    @Test
    func reduce_loadPackages_setsLoadingStateAndClearsError() {
        var state = SubscriptionState()
        state.errorMessage = "Previous error"

        SubscriptionReducer.reduce(state: &state, action: .loadPackages)

        #expect(state.isLoading == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_packagesLoaded_setsPackagesAndClearsLoading() {
        var state = SubscriptionState()
        state.isLoading = true

        let packages = [
            SubscriptionPackage(
                id: "$rc_monthly",
                localizedTitle: "Premium Monthly",
                localizedPriceString: "¥480",
                productIdentifier: "premium_1month"
            )
        ]

        SubscriptionReducer.reduce(state: &state, action: .packagesLoaded(packages))

        #expect(state.availablePackages.count == 1)
        #expect(state.availablePackages.first?.id == "$rc_monthly")
        #expect(state.isLoading == false)
    }

    @Test
    func reduce_packagesLoadFailed_setsErrorAndClearsLoading() {
        var state = SubscriptionState()
        state.isLoading = true

        SubscriptionReducer.reduce(state: &state, action: .packagesLoadFailed("パッケージ取得失敗"))

        #expect(state.errorMessage == "パッケージ取得失敗")
        #expect(state.isLoading == false)
    }

    // MARK: - Purchase Tests

    @Test
    func reduce_purchase_setsPurchasingState() {
        var state = SubscriptionState()

        SubscriptionReducer.reduce(state: &state, action: .purchase(packageID: "$rc_monthly"))

        #expect(state.isPurchasing == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_purchase_clearsExistingError() {
        var state = SubscriptionState()
        state.errorMessage = "前回のエラー"

        SubscriptionReducer.reduce(state: &state, action: .purchase(packageID: "$rc_monthly"))

        #expect(state.errorMessage == nil)
        #expect(state.isPurchasing == true)
    }

    @Test
    func reduce_purchaseSucceeded_setsPremiumAndClearsPurchasingAndHidesPaywall() {
        var state = SubscriptionState()
        state.isPurchasing = true
        state.showsPaywall = true

        SubscriptionReducer.reduce(state: &state, action: .purchaseSucceeded)

        #expect(state.isPremium == true)
        #expect(state.isPurchasing == false)
        #expect(state.showsPaywall == false)
    }

    @Test
    func reduce_purchaseFailed_setsErrorAndClearsPurchasing() {
        var state = SubscriptionState()
        state.isPurchasing = true

        SubscriptionReducer.reduce(state: &state, action: .purchaseFailed("購入に失敗しました"))

        #expect(state.errorMessage == "購入に失敗しました")
        #expect(state.isPurchasing == false)
    }

    @Test
    func reduce_purchaseCancelled_clearsPurchasingWithoutError() {
        var state = SubscriptionState()
        state.isPurchasing = true

        SubscriptionReducer.reduce(state: &state, action: .purchaseCancelled)

        #expect(state.isPurchasing == false)
        #expect(state.errorMessage == nil)
    }

    // MARK: - Restore Tests

    @Test
    func reduce_restorePurchases_setsRestoringState() {
        var state = SubscriptionState()

        SubscriptionReducer.reduce(state: &state, action: .restorePurchases)

        #expect(state.isRestoring == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_restoreSucceeded_setsIsPremiumAndClearsRestoring() {
        var state = SubscriptionState()
        state.isRestoring = true

        SubscriptionReducer.reduce(state: &state, action: .restoreSucceeded(isPremium: true))

        #expect(state.isPremium == true)
        #expect(state.isRestoring == false)
    }

    @Test
    func reduce_restoreSucceeded_whenNotPremium_keepsPremiumFalse() {
        var state = SubscriptionState()
        state.isRestoring = true
        state.isPremium = false

        SubscriptionReducer.reduce(state: &state, action: .restoreSucceeded(isPremium: false))

        #expect(state.isPremium == false)
        #expect(state.isRestoring == false)
    }

    @Test
    func reduce_restoreFailed_setsErrorAndClearsRestoring() {
        var state = SubscriptionState()
        state.isRestoring = true

        SubscriptionReducer.reduce(state: &state, action: .restoreFailed("復元に失敗しました"))

        #expect(state.errorMessage == "復元に失敗しました")
        #expect(state.isRestoring == false)
    }

    // MARK: - Clear Error Tests

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = SubscriptionState()
        state.errorMessage = "エラーが発生しました"

        SubscriptionReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }
}
