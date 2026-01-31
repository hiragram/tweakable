import SwiftUI

/// Container view that connects PaywallView to AppStore
struct PaywallContainerView: View {
    let store: AppStore

    var body: some View {
        PaywallView(
            packages: store.state.subscription.availablePackages,
            isPurchasing: store.state.subscription.isPurchasing,
            isRestoring: store.state.subscription.isRestoring,
            errorMessage: store.state.subscription.errorMessage,
            onPurchase: { packageID in
                store.send(.subscription(.purchase(packageID: packageID)))
            },
            onRestore: {
                store.send(.subscription(.restorePurchases))
            },
            onDismiss: {
                store.send(.subscription(.hidePaywall))
            }
        )
        .task {
            // Load packages when paywall appears
            store.send(.subscription(.loadPackages))
        }
    }
}
