import Prefire
import SwiftUI

// MARK: - InviteCodeView

/// 招待コードを生成・表示するView（オーナー用）
struct InviteCodeView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case closeButton
        case copyCodeButton
        case generateButton

        public var rawIdentifier: String {
            switch self {
            case .closeButton:
                return "inviteCode_button_close"
            case .copyCodeButton:
                return "inviteCode_button_copyCode"
            case .generateButton:
                return "inviteCode_button_generate"
            }
        }
    }

    // MARK: - Properties

    /// 招待コードを生成中かどうか
    let isCreating: Bool

    /// 生成された招待コード
    let generatedCode: String?

    /// エラーメッセージ
    let errorMessage: String?

    /// グループ名
    let groupName: String

    /// 閉じるボタンのコールバック
    let onDismiss: () -> Void

    /// 生成ボタンのコールバック
    let onGenerate: () -> Void

    // MARK: - Local State

    @State private var showCopiedFeedback = false

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.xl) {
                        Spacer()
                            .frame(height: theme.spacing.lg)

                        headerSection

                        contentSection

                        Spacer()
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.xl)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(String(localized: "invite_code_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common_close", bundle: .app)) {
                        onDismiss()
                    }
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier(AccessibilityID.closeButton)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: theme.spacing.md) {
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

                Image(systemName: "qrcode")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.colors.primaryBrand.color, theme.colors.secondaryBrand.color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: theme.spacing.xs) {
                Text("invite_code_header_title", bundle: .app)
                    .font(theme.typography.displaySmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text(String(format: String(localized: "invite_code_header_description %@", bundle: .app), groupName))
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        if isCreating {
            creatingContent
        } else if let code = generatedCode {
            successContent(code: code)
        } else if let error = errorMessage {
            errorContent(message: error)
        } else {
            idleContent
        }
    }

    // MARK: - Idle Content

    private var idleContent: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text("invite_code_about_title", bundle: .app)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text("invite_code_about_description", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )

            Button {
                onGenerate()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))

                    Text("invite_code_generate", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.generateButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Creating Content

    private var creatingContent: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                    .scaleEffect(1.5)

                Text("invite_code_generating", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }
            .padding(.vertical, theme.spacing.xxl)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Success Content

    private func successContent(code: String) -> some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.md) {
                Text("invite_code_title", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)

                Button {
                    UIPasteboard.general.string = code
                    showCopiedFeedback = true
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        showCopiedFeedback = false
                    }
                } label: {
                    VStack(spacing: theme.spacing.sm) {
                        Text(code)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.colors.primaryBrand.color)
                            .kerning(8)

                        HStack(spacing: theme.spacing.xxs) {
                            if showCopiedFeedback {
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.colors.success.color)
                                Text("invite_member_copied", bundle: .app)
                                    .foregroundColor(theme.colors.success.color)
                            } else {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(theme.colors.textTertiary.color)
                                Text("invite_member_tap_to_copy", bundle: .app)
                                    .foregroundColor(theme.colors.textTertiary.color)
                            }
                        }
                        .font(theme.typography.captionLarge.font)
                    }
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.success, trigger: showCopiedFeedback)
                .accessibilityIdentifier(AccessibilityID.copyCodeButton)
            }
            .padding(.vertical, theme.spacing.xxl)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )

            Text("invite_code_share_hint", bundle: .app)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textTertiary.color)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Error Content

    private func errorContent(message: String) -> some View {
        VStack(spacing: theme.spacing.lg) {
            ZStack {
                Circle()
                    .fill(theme.colors.error.color.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(theme.colors.error.color)
            }

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.colors.error.color)

                    Text("common_error", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                Text(message)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.error.color.opacity(0.08))
            )

            Button {
                onGenerate()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))

                    Text("common_retry", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.generateButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }
}

// MARK: - Previews

#Preview("InviteCodeView_Okumuka - Idle") {
    InviteCodeView_Okumuka(
        isCreating: false,
        generatedCode: nil,
        errorMessage: nil,
        groupName: "山田家",
        onDismiss: {},
        onGenerate: {}
    )
}

#Preview("InviteCodeView_Okumuka - Creating") {
    InviteCodeView_Okumuka(
        isCreating: true,
        generatedCode: nil,
        errorMessage: nil,
        groupName: "山田家",
        onDismiss: {},
        onGenerate: {}
    )
}

#Preview("InviteCodeView_Okumuka - Success") {
    InviteCodeView_Okumuka(
        isCreating: false,
        generatedCode: "ABC123",
        errorMessage: nil,
        groupName: "山田家",
        onDismiss: {},
        onGenerate: {}
    )
}

#Preview("InviteCodeView_Okumuka - Error") {
    InviteCodeView_Okumuka(
        isCreating: false,
        generatedCode: nil,
        errorMessage: "ネットワークエラーが発生しました",
        groupName: "山田家",
        onDismiss: {},
        onGenerate: {}
    )
}
