import SwiftUI

/// Paywall UI for premium subscription
struct PaywallView: View {
    private let ds = DesignSystem.default

    /// Available packages to display
    let packages: [SubscriptionPackage]

    /// Whether a purchase is in progress
    let isPurchasing: Bool

    /// Whether a restore is in progress
    let isRestoring: Bool

    /// Error message to display
    let errorMessage: String?

    /// Called when a package is selected for purchase
    let onPurchase: (String) -> Void

    /// Called when restore button is tapped
    let onRestore: () -> Void

    /// Called when dismiss button is tapped
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: ds.spacing.lg) {
                // Header
                headerSection

                // Features
                featuresSection

                Spacer()

                // Packages
                packagesSection

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(ds.typography.captionLarge.font)
                        .foregroundStyle(ds.colors.error.color)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ds.spacing.md)
                }

                // Restore button
                restoreButton

                // Terms
                termsSection
            }
            .padding(ds.spacing.md)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(ds.colors.textSecondary.color)
                    }
                    .accessibilityIdentifier("paywall_button_dismiss")
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: ds.spacing.sm) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(ds.colors.secondaryBrand.color)

            Text(String(localized: "paywall_title", bundle: .app))
                .font(ds.typography.displayMedium.font)
                .foregroundColor(ds.colors.textPrimary.color)

            Text(String(localized: "paywall_subtitle", bundle: .app))
                .font(ds.typography.bodyMedium.font)
                .foregroundStyle(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            featureRow(icon: "arrow.triangle.swap", text: String(localized: "paywall_feature_substitution", bundle: .app))
            featureRow(icon: "wand.and.stars", text: String(localized: "paywall_feature_ai", bundle: .app))
            featureRow(icon: "infinity", text: String(localized: "paywall_feature_unlimited", bundle: .app))
        }
        .padding(ds.spacing.md)
        .background(ds.colors.backgroundSecondary.color)
        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: ds.spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(ds.colors.primaryBrand.color)
                .frame(width: ds.layout.iconSize)
            Text(text)
                .font(ds.typography.bodyMedium.font)
                .foregroundColor(ds.colors.textPrimary.color)
            Spacer()
        }
    }

    // MARK: - Packages Section

    private var packagesSection: some View {
        VStack(spacing: ds.spacing.sm) {
            ForEach(packages) { package in
                packageButton(package)
            }
        }
    }

    private func packageButton(_ package: SubscriptionPackage) -> some View {
        Button {
            onPurchase(package.id)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: ds.spacing.xxs) {
                    Text(package.localizedTitle)
                        .font(ds.typography.headlineLarge.font)
                        .foregroundColor(ds.colors.textPrimary.color)
                    Text(package.localizedPriceString)
                        .font(ds.typography.bodyMedium.font)
                        .foregroundStyle(ds.colors.textSecondary.color)
                }
                Spacer()
                if isPurchasing {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(ds.colors.textTertiary.color)
                }
            }
            .padding(ds.spacing.md)
            .background(ds.colors.backgroundTertiary.color)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
        }
        .disabled(isPurchasing || isRestoring)
        .accessibilityIdentifier("paywall_button_purchase_\(package.id)")
    }

    // MARK: - Restore Button

    private var restoreButton: some View {
        Button {
            onRestore()
        } label: {
            if isRestoring {
                ProgressView()
            } else {
                Text(String(localized: "paywall_restore", bundle: .app))
                    .font(ds.typography.bodyMedium.font)
                    .foregroundStyle(ds.colors.primaryBrand.color)
            }
        }
        .disabled(isPurchasing || isRestoring)
        .accessibilityIdentifier("paywall_button_restore")
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        Text(String(localized: "paywall_terms", bundle: .app))
            .font(ds.typography.captionSmall.font)
            .foregroundStyle(ds.colors.textTertiary.color)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Preview

#Preview {
    PaywallView(
        packages: [
            SubscriptionPackage(
                id: "$rc_monthly",
                localizedTitle: "Premium Monthly",
                localizedPriceString: "$4.99/month",
                productIdentifier: "premium_1month"
            )
        ],
        isPurchasing: false,
        isRestoring: false,
        errorMessage: nil,
        onPurchase: { _ in },
        onRestore: {},
        onDismiss: {}
    )
    .prefireEnabled()
}
