import Foundation
import RevenueCat

/// RevenueCatサービスの実装
public final class RevenueCatService: RevenueCatServiceProtocol, @unchecked Sendable {
    // MARK: - Constants

    /// Entitlement ID（RevenueCat Dashboardで設定）
    private static let premiumEntitlementID = "premium"

    // MARK: - Initialization

    public init() {}

    // MARK: - RevenueCatServiceProtocol

    public func checkPremiumStatus() async throws -> Bool {
        let customerInfo = try await Purchases.shared.customerInfo()
        return customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true
    }

    public func fetchPackages() async throws -> [SubscriptionPackage] {
        let offerings = try await Purchases.shared.offerings()

        guard let currentOffering = offerings.current else {
            return []
        }

        return currentOffering.availablePackages.map { package in
            SubscriptionPackage(
                id: package.identifier,
                localizedTitle: package.storeProduct.localizedTitle,
                localizedPriceString: package.localizedPriceString,
                productIdentifier: package.storeProduct.productIdentifier
            )
        }
    }

    public func purchase(packageID: String) async throws -> PurchaseResult {
        let offerings = try await Purchases.shared.offerings()

        guard let currentOffering = offerings.current,
              let package = currentOffering.package(identifier: packageID) else {
            throw RevenueCatServiceError.purchaseFailed("Package not found: \(packageID)")
        }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if result.userCancelled {
                return .cancelled
            }

            return .success
        } catch {
            if let purchasesError = error as? RevenueCat.ErrorCode {
                if purchasesError == .purchaseCancelledError {
                    return .cancelled
                }
            }
            throw RevenueCatServiceError.purchaseFailed(error.localizedDescription)
        }
    }

    public func restorePurchases() async throws -> Bool {
        let customerInfo = try await Purchases.shared.restorePurchases()
        return customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true
    }
}
