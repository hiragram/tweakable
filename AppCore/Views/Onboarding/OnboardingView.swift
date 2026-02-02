import SwiftUI

/// Onboarding flow with 3 pages introducing the app's features
struct OnboardingView: View {
    private let ds = DesignSystem.default

    @Environment(\.colorScheme) private var colorScheme

    /// Current page index (0-2)
    @State private var currentPage: Int

    /// Called when the user completes onboarding
    let onComplete: () -> Void

    private let totalPages = 3

    init(initialPage: Int = 0, onComplete: @escaping () -> Void) {
        _currentPage = State(initialValue: initialPage)
        self.onComplete = onComplete
    }

    /// Background colors for each page (light mode)
    private let lightPageColors: [Color] = [
        Color(red: 1.0, green: 0.95, blue: 0.9),   // Page 1: Warm peach
        Color(red: 0.9, green: 0.95, blue: 1.0),   // Page 2: Soft blue
        Color(red: 0.9, green: 1.0, blue: 0.92),   // Page 3: Mint green
    ]

    /// Background colors for each page (dark mode)
    private let darkPageColors: [Color] = [
        Color(red: 0.25, green: 0.18, blue: 0.15),  // Page 1: Dark peach
        Color(red: 0.15, green: 0.18, blue: 0.25),  // Page 2: Dark blue
        Color(red: 0.15, green: 0.22, blue: 0.18),  // Page 3: Dark mint
    ]

    private var currentBackgroundColor: Color {
        let colors = colorScheme == .dark ? darkPageColors : lightPageColors
        return colors[currentPage]
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingPageView.recipeCollection()
                    .tag(0)

                OnboardingPageView.customization()
                    .tag(1)

                OnboardingPageView.shoppingList()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Navigation button
            buttonSection
                .padding(.horizontal, ds.spacing.xl)
                .padding(.bottom, ds.spacing.xl)
        }
        .background {
            currentBackgroundColor.animation(.easeInOut(duration: 0.3), value: currentPage)
                .ignoresSafeArea()
        }
    }

    // MARK: - Button Section

    @ViewBuilder
    private var buttonSection: some View {
        if currentPage < totalPages - 1 {
            Button {
                withAnimation {
                    currentPage += 1
                }
            } label: {
                Text(.onboardingNext)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("onboarding_button_next")
        } else {
            Button {
                onComplete()
            } label: {
                Text(.onboardingGetStarted)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("onboarding_button_getStarted")
        }
    }
}

// MARK: - Preview

#Preview("Page 1 - Recipe Collection") {
    OnboardingView(initialPage: 0, onComplete: {})
        .prefireEnabled()
}

#Preview("Page 2 - Customization") {
    OnboardingView(initialPage: 1, onComplete: {})
        .prefireEnabled()
}

#Preview("Page 3 - Shopping List") {
    OnboardingView(initialPage: 2, onComplete: {})
        .prefireEnabled()
}
