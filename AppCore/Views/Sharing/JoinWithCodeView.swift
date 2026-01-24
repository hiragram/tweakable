import Prefire
import SwiftUI

// MARK: - JoinWithCodeView

/// 招待コードを入力してグループに参加するView（参加者用）
struct JoinWithCodeView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case closeButton
        case codeTextField
        case joinButton
        case retryButton

        public var rawIdentifier: String {
            switch self {
            case .closeButton:
                return "joinWithCode_button_close"
            case .codeTextField:
                return "joinWithCode_textField_code"
            case .joinButton:
                return "joinWithCode_button_join"
            case .retryButton:
                return "joinWithCode_button_retry"
            }
        }
    }

    // MARK: - Properties

    /// 入力された招待コード
    @Binding var codeInput: String

    /// 参加処理中かどうか
    let isJoining: Bool

    /// 参加成功したグループ
    let joinedGroup: SupabaseUserGroup?

    /// エラーメッセージ
    let errorMessage: String?

    /// 閉じるボタンのコールバック
    let onDismiss: () -> Void

    /// 参加ボタンのコールバック
    let onJoin: () -> Void

    // MARK: - Local State

    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Computed Properties

    private var isJoinButtonEnabled: Bool {
        codeInput.count == 6 && !isJoining
    }

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
            .navigationTitle(String(localized: "join_with_code_title", bundle: .app))
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

                Image(systemName: "person.badge.plus")
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
                Text("join_with_code_header_title", bundle: .app)
                    .font(theme.typography.displaySmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text("join_with_code_header_description", bundle: .app)
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
        if isJoining {
            joiningContent
        } else if let group = joinedGroup {
            successContent(group: group)
        } else if let error = errorMessage {
            errorContent(message: error)
        } else {
            inputContent
        }
    }

    // MARK: - Input Content

    private var inputContent: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.md) {
                TextField("", text: $codeInput)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.vertical, theme.spacing.md)
                    .padding(.horizontal, theme.spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                            .fill(theme.colors.backgroundSecondary.color)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                            .stroke(
                                isTextFieldFocused
                                    ? theme.colors.primaryBrand.color
                                    : theme.colors.border.color,
                                lineWidth: isTextFieldFocused ? 2 : 1
                            )
                    )
                    .focused($isTextFieldFocused)
                    .onChange(of: codeInput) { _, newValue in
                        // 6文字まで、英数大文字のみ
                        let filtered = String(newValue.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(6))
                        if filtered != codeInput {
                            codeInput = filtered
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.codeTextField)

                Text("join_with_code_input_label", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            }

            Button {
                onJoin()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18, weight: .medium))

                    Text("join_with_code_join_button", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .disabled(!isJoinButtonEnabled)
            .accessibilityIdentifier(AccessibilityID.joinButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Joining Content

    private var joiningContent: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                    .scaleEffect(1.5)

                Text("join_with_code_joining", bundle: .app)
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

    private func successContent(group: SupabaseUserGroup) -> some View {
        VStack(spacing: theme.spacing.lg) {
            ZStack {
                Circle()
                    .fill(theme.colors.success.color.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(theme.colors.success.color)
            }

            VStack(spacing: theme.spacing.sm) {
                Text("join_with_code_success_title", bundle: .app)
                    .font(theme.typography.headlineMedium.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text(String(format: String(localized: "join_with_code_success_message %@", bundle: .app), group.name))
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }

            Button {
                onDismiss()
            } label: {
                Text("common_close", bundle: .app)
                    .font(theme.typography.buttonLarge.font)
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
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
                onJoin()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))

                    Text("common_retry", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.retryButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }
}

// MARK: - Previews

#Preview("JoinWithCodeView - Idle") {
    JoinWithCodeView(
        codeInput: .constant(""),
        isJoining: false,
        joinedGroup: nil,
        errorMessage: nil,
        onDismiss: {},
        onJoin: {}
    )
    .prefireEnabled()
}

#Preview("JoinWithCodeView - Input") {
    JoinWithCodeView(
        codeInput: .constant("ABC1"),
        isJoining: false,
        joinedGroup: nil,
        errorMessage: nil,
        onDismiss: {},
        onJoin: {}
    )
    .prefireEnabled()
}

#Preview("JoinWithCodeView - Joining") {
    JoinWithCodeView(
        codeInput: .constant("ABC123"),
        isJoining: true,
        joinedGroup: nil,
        errorMessage: nil,
        onDismiss: {},
        onJoin: {}
    )
    .prefireEnabled()
}

#Preview("JoinWithCodeView - Success") {
    JoinWithCodeView(
        codeInput: .constant("ABC123"),
        isJoining: false,
        joinedGroup: SupabaseUserGroup(
            id: UUID(),
            name: "山田家",
            ownerID: UUID()
        ),
        errorMessage: nil,
        onDismiss: {},
        onJoin: {}
    )
    .prefireEnabled()
}

#Preview("JoinWithCodeView - Error") {
    JoinWithCodeView(
        codeInput: .constant("ABC123"),
        isJoining: false,
        joinedGroup: nil,
        errorMessage: "招待コードが見つかりません",
        onDismiss: {},
        onJoin: {}
    )
    .prefireEnabled()
}
