import Prefire
import SwiftUI

/// メールアドレス入力画面（ログイン）
struct EmailInputView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case emailTextField
        case sendOTPButton

        public var rawIdentifier: String {
            switch self {
            case .emailTextField:
                return "emailInput_textField_email"
            case .sendOTPButton:
                return "emailInput_button_sendOTP"
            }
        }
    }

    let email: String
    let isSending: Bool
    let errorMessage: String?
    let onEmailChanged: (String) -> Void
    let onSendOTP: () -> Void

    private let theme = DesignSystem.default

    private var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.xl) {
                Spacer()

                // Icon
                Image(systemName: "envelope.fill")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.primaryBrand.color)

                // Title
                VStack(spacing: theme.spacing.sm) {
                    Text("auth_login_title", bundle: .app)
                        .font(theme.typography.displayLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    Text("auth_email_description", bundle: .app)
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textSecondary.color)
                }

                Spacer()

                // Email input
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("auth_email_label", bundle: .app)
                        .font(theme.typography.bodySmall.font)
                        .foregroundColor(theme.colors.textSecondary.color)

                    TextField("example@email.com", text: Binding(
                        get: { email },
                        set: { onEmailChanged($0) }
                    ))
                    .textFieldStyle(RoundedTextFieldStyle(theme: theme))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .accessibilityIdentifier(AccessibilityID.emailTextField)

                    Text("auth_otp_will_send", bundle: .app)
                        .font(theme.typography.captionSmall.font)
                        .foregroundColor(theme.colors.textTertiary.color)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(theme.typography.captionSmall.font)
                            .foregroundColor(theme.colors.error.color)
                    }
                }
                .padding(.horizontal, theme.spacing.md)

                Spacer()

                // Send OTP button
                Button {
                    onSendOTP()
                } label: {
                    if isSending {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("auth_send_otp", bundle: .app)
                    }
                }
                .buttonStyle(PrimaryButtonStyle(theme: theme))
                .disabled(!isEmailValid || isSending)
                .accessibilityIdentifier(AccessibilityID.sendOTPButton)
                .padding(.horizontal, theme.spacing.md)
                .padding(.bottom, theme.spacing.xl)
            }
        }
    }
}

#Preview("EmailInputView") {
    EmailInputView(
        email: "",
        isSending: false,
        errorMessage: nil,
        onEmailChanged: { _ in },
        onSendOTP: {}
    )
    .prefireEnabled()
}

#Preview("EmailInputView_WithEmail") {
    EmailInputView(
        email: "test@example.com",
        isSending: false,
        errorMessage: nil,
        onEmailChanged: { _ in },
        onSendOTP: {}
    )
    .prefireEnabled()
}

#Preview("EmailInputView_Sending") {
    EmailInputView(
        email: "test@example.com",
        isSending: true,
        errorMessage: nil,
        onEmailChanged: { _ in },
        onSendOTP: {}
    )
    .prefireEnabled()
}

#Preview("EmailInputView_Error") {
    EmailInputView(
        email: "test@example.com",
        isSending: false,
        errorMessage: "メールの送信に失敗しました",
        onEmailChanged: { _ in },
        onSendOTP: {}
    )
    .prefireEnabled()
}
