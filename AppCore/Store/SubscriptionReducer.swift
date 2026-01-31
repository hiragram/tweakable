import Foundation

/// サブスクリプション機能のReducer
public enum SubscriptionReducer {
    public static func reduce(state: inout SubscriptionState, action: SubscriptionAction) {
        switch action {
        case .loadSubscriptionStatus:
            state.isLoading = true
            state.errorMessage = nil

        case .subscriptionStatusLoaded(let isPremium):
            state.isLoading = false
            state.isPremium = isPremium

        case .subscriptionStatusLoadFailed(let message):
            state.isLoading = false
            state.errorMessage = message

        case .showPaywall:
            state.showsPaywall = true

        case .hidePaywall:
            state.showsPaywall = false

        case .loadPackages:
            state.isLoading = true
            state.errorMessage = nil

        case .packagesLoaded(let packages):
            state.isLoading = false
            state.availablePackages = packages

        case .packagesLoadFailed(let message):
            state.isLoading = false
            state.errorMessage = message

        case .purchase:
            state.isPurchasing = true
            state.errorMessage = nil

        case .purchaseSucceeded:
            state.isPurchasing = false
            state.isPremium = true
            state.showsPaywall = false

        case .purchaseFailed(let message):
            state.isPurchasing = false
            state.errorMessage = message

        case .purchaseCancelled:
            state.isPurchasing = false

        case .restorePurchases:
            state.isRestoring = true
            state.errorMessage = nil

        case .restoreSucceeded(let isPremium):
            state.isRestoring = false
            state.isPremium = isPremium

        case .restoreFailed(let message):
            state.isRestoring = false
            state.errorMessage = message

        case .clearError:
            state.errorMessage = nil
        }
    }
}
