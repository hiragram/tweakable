import Prefire
import SwiftUI

/// iCloud確認中などのローディング画面
struct LoadingView_Okumuka: View {
    // MARK: - Parameters

    let message: String

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colors.primaryBrand.color.opacity(0.2),
                                    theme.colors.secondaryBrand.color.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "icloud")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.colors.primaryBrand.color, theme.colors.secondaryBrand.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: theme.spacing.sm) {
                    Text(message)
                        .font(theme.typography.headlineLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                        .scaleEffect(1.2)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("LoadingView_Okumuka") {
    LoadingView_Okumuka(message: "iCloudを確認中...")
}

