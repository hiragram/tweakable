import Prefire
import SwiftUI

/// 承認待ち状態を表示するビュー（参加者用）
struct WaitingForApprovalView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case view
        case reloadButton

        public var rawIdentifier: String {
            switch self {
            case .view:
                return "waitingForApproval_view"
            case .reloadButton:
                return "waitingForApproval_button_reload"
            }
        }
    }

    // MARK: - Properties

    /// グループ名
    let groupName: String

    /// 読み込み中かどうか
    let isLoading: Bool

    /// 再読み込みボタンが押されたときのコールバック
    let onReload: () -> Void

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.xl) {
                Spacer()

                iconSection

                textSection

                infoCard

                reloadButton

                Spacer()
            }
            .padding(.horizontal, theme.spacing.lg)
        }
        .accessibilityIdentifier(AccessibilityID.view)
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colors.info.color.opacity(0.2),
                            theme.colors.primaryBrand.color.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)

            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.info.color, theme.colors.primaryBrand.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(spacing: theme.spacing.sm) {
            Text("waiting_for_approval_title", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Text(String(localized: "waiting_for_approval_description \(groupName)", bundle: .app))
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.info.color)

                Text("waiting_for_approval_info_title", bundle: .app)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)
            }

            Text("waiting_for_approval_info_message", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .lineSpacing(4)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.backgroundSecondary.color)
        )
    }

    // MARK: - Reload Button

    private var reloadButton: some View {
        Button(action: onReload) {
            HStack(spacing: theme.spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                }

                Text("waiting_for_approval_reload_button", bundle: .app)
                    .font(theme.typography.buttonMedium.font)
            }
            .foregroundColor(isLoading ? theme.colors.textSecondary.color : theme.colors.primaryBrand.color)
            .padding(.vertical, theme.spacing.sm)
            .padding(.horizontal, theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.primaryBrand.color.opacity(isLoading ? 0.05 : 0.1))
            )
        }
        .disabled(isLoading)
        .accessibilityIdentifier(AccessibilityID.reloadButton)
    }
}

// MARK: - Previews

#Preview("WaitingForApprovalView_Okumuka") {
    WaitingForApprovalView_Okumuka(groupName: "山田家", isLoading: false, onReload: {})
}

#Preview("WaitingForApprovalView_Okumuka - Loading") {
    WaitingForApprovalView_Okumuka(groupName: "山田家", isLoading: true, onReload: {})
}
