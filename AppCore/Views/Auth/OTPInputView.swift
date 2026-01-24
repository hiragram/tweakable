import Prefire
import SwiftUI

/// OTP（6桁認証コード）入力画面
struct OTPInputView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case otpTextField
        case verifyButton
        case resendButton

        public var rawIdentifier: String {
            switch self {
            case .otpTextField:
                return "otpInput_textField_otp"
            case .verifyButton:
                return "otpInput_button_verify"
            case .resendButton:
                return "otpInput_button_resend"
            }
        }
    }

    let email: String
    let otp: String
    let isVerifying: Bool
    let errorMessage: String?
    let onOTPChanged: (String) -> Void
    let onVerify: () -> Void
    let onResend: () -> Void
    let onBack: () -> Void

    private let theme = DesignSystem.default

    private var isOTPValid: Bool {
        otp.count == 6 && otp.allSatisfy { $0.isNumber }
    }

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.xl) {
                // Back button
                HStack {
                    Button {
                        onBack()
                    } label: {
                        HStack(spacing: theme.spacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("auth_back", bundle: .app)
                        }
                        .foregroundColor(theme.colors.primaryBrand.color)
                    }
                    Spacer()
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.top, theme.spacing.md)

                Spacer()

                // Icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.primaryBrand.color)

                // Title
                VStack(spacing: theme.spacing.sm) {
                    Text("auth_otp_title", bundle: .app)
                        .font(theme.typography.displayLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    Text(String(format: String(localized: "auth_otp_sent_to %@", bundle: .app), email))
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textSecondary.color)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // OTP input
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("auth_otp_label", bundle: .app)
                        .font(theme.typography.bodySmall.font)
                        .foregroundColor(theme.colors.textSecondary.color)

                    TextField("000000", text: Binding(
                        get: { otp },
                        set: { newValue in
                            // 数字のみ、最大6桁
                            let filtered = newValue.filter { $0.isNumber }
                            let limited = String(filtered.prefix(6))
                            onOTPChanged(limited)
                        }
                    ))
                    .textFieldStyle(RoundedTextFieldStyle(theme: theme))
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .accessibilityIdentifier(AccessibilityID.otpTextField)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(theme.typography.captionSmall.font)
                            .foregroundColor(theme.colors.error.color)
                    }

                    // Resend button
                    HStack {
                        Spacer()
                        Button {
                            onResend()
                        } label: {
                            Text("auth_resend_code", bundle: .app)
                                .font(theme.typography.bodySmall.font)
                                .foregroundColor(theme.colors.primaryBrand.color)
                        }
                        .accessibilityIdentifier(AccessibilityID.resendButton)
                        Spacer()
                    }
                    .padding(.top, theme.spacing.sm)
                }
                .padding(.horizontal, theme.spacing.md)

                Spacer()

                // Verify button
                Button {
                    onVerify()
                } label: {
                    if isVerifying {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("auth_verify", bundle: .app)
                    }
                }
                .buttonStyle(PrimaryButtonStyle(theme: theme))
                .disabled(!isOTPValid || isVerifying)
                .accessibilityIdentifier(AccessibilityID.verifyButton)
                .padding(.horizontal, theme.spacing.md)
                .padding(.bottom, theme.spacing.xl)
            }
        }
    }
}

#Preview("OTPInputView") {
    OTPInputView(
        email: "test@example.com",
        otp: "",
        isVerifying: false,
        errorMessage: nil,
        onOTPChanged: { _ in },
        onVerify: {},
        onResend: {},
        onBack: {}
    )
    .prefireEnabled()
}

#Preview("OTPInputView_WithOTP") {
    OTPInputView(
        email: "test@example.com",
        otp: "123456",
        isVerifying: false,
        errorMessage: nil,
        onOTPChanged: { _ in },
        onVerify: {},
        onResend: {},
        onBack: {}
    )
    .prefireEnabled()
}

#Preview("OTPInputView_Verifying") {
    OTPInputView(
        email: "test@example.com",
        otp: "123456",
        isVerifying: true,
        errorMessage: nil,
        onOTPChanged: { _ in },
        onVerify: {},
        onResend: {},
        onBack: {}
    )
    .prefireEnabled()
}

#Preview("OTPInputView_Error") {
    OTPInputView(
        email: "test@example.com",
        otp: "123456",
        isVerifying: false,
        errorMessage: "認証コードが正しくありません",
        onOTPChanged: { _ in },
        onVerify: {},
        onResend: {},
        onBack: {}
    )
    .prefireEnabled()
}
