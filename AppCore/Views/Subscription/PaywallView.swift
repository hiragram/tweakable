import SwiftUI

/// Paywall UI for premium subscription
struct PaywallView: View {
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
            VStack(spacing: 24) {
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
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Restore button
                restoreButton

                // Terms
                termsSection
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityIdentifier("paywall_button_dismiss")
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text(String(localized: "paywall_title", bundle: .app))
                .font(.title)
                .fontWeight(.bold)

            Text(String(localized: "paywall_subtitle", bundle: .app))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: "arrow.triangle.swap", text: String(localized: "paywall_feature_substitution", bundle: .app))
            featureRow(icon: "wand.and.stars", text: String(localized: "paywall_feature_ai", bundle: .app))
            featureRow(icon: "infinity", text: String(localized: "paywall_feature_unlimited", bundle: .app))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }

    // MARK: - Packages Section

    private var packagesSection: some View {
        VStack(spacing: 12) {
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
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.localizedTitle)
                        .font(.headline)
                    Text(package.localizedPriceString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isPurchasing {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
        .disabled(isPurchasing || isRestoring)
        .accessibilityIdentifier("paywall_button_restore")
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        Text(String(localized: "paywall_terms", bundle: .app))
            .font(.caption2)
            .foregroundStyle(.secondary)
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
