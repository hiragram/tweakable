import SwiftUI
import Prefire

/// A single page in the onboarding flow
struct OnboardingPageView: View {
    private let ds = DesignSystem.default

    /// SF Symbol name for the icon (used if imageName is nil)
    let icon: String

    /// Asset image name (if provided, used instead of icon)
    let imageName: String?

    /// Title text (localized)
    let title: LocalizedStringResource

    /// Subtitle text (localized)
    let subtitle: LocalizedStringResource

    init(icon: String, imageName: String? = nil, title: LocalizedStringResource, subtitle: LocalizedStringResource) {
        self.icon = icon
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: ds.spacing.lg) {
            Spacer()

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280, maxHeight: 280)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(ds.colors.primaryBrand.color)
            }

            Text(title)
                .font(ds.typography.displayMedium.font)
                .foregroundStyle(ds.colors.textPrimary.color)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(ds.typography.bodyMedium.font)
                .foregroundStyle(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, ds.spacing.xl)
    }

    // MARK: - Factory Methods

    /// Page 1: Recipe URL collection
    static func recipeCollection() -> OnboardingPageView {
        OnboardingPageView(
            icon: "link.badge.plus",
            imageName: "onboarding-recipe-cards",
            title: .onboardingPage1Title,
            subtitle: .onboardingPage1Subtitle
        )
    }

    /// Page 2: Ingredient/step customization
    static func customization() -> OnboardingPageView {
        OnboardingPageView(
            icon: "arrow.triangle.swap",
            imageName: "onboarding-ingredient-swap",
            title: .onboardingPage2Title,
            subtitle: .onboardingPage2Subtitle
        )
    }

    /// Page 3: Shopping list generation
    static func shoppingList() -> OnboardingPageView {
        OnboardingPageView(
            icon: "cart.fill",
            imageName: "onboarding-shopping-list",
            title: .onboardingPage3Title,
            subtitle: .onboardingPage3Subtitle
        )
    }
}

// MARK: - Preview

#Preview("OnboardingPageView - Recipe") {
    OnboardingPageView.recipeCollection()
        .prefireEnabled()
}

#Preview("OnboardingPageView - Customize") {
    OnboardingPageView.customization()
        .prefireEnabled()
}

#Preview("OnboardingPageView - ShoppingList") {
    OnboardingPageView.shoppingList()
        .prefireEnabled()
}
