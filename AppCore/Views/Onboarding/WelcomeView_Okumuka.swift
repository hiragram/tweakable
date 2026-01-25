import Prefire
import SwiftUI

/// 初回起動時のウェルカム画面（名前入力）
struct WelcomeView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case userNameTextField
        case startButton

        public var rawIdentifier: String {
            switch self {
            case .userNameTextField:
                return "welcome_textField_userName"
            case .startButton:
                return "welcome_button_start"
            }
        }
    }

    @State private var userName: String = ""
    @State private var isLoading = false
    let onComplete: (String) -> Void

    private let theme = DesignSystem.default

    private var isNameValid: Bool {
        !userName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.xl) {
                Spacer()

                // Icon
                Image(systemName: "figure.2.and.child.holdinghands")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.primaryBrand.color)

                // Title
                VStack(spacing: theme.spacing.sm) {
                    Text("Tweakable")
                        .font(theme.typography.displayLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    Text("welcome_subtitle", bundle: .app)
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textSecondary.color)
                }

                Spacer()

                // Name input
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("welcome_name_prompt", bundle: .app)
                        .font(theme.typography.bodySmall.font)
                        .foregroundColor(theme.colors.textSecondary.color)

                    TextField(String(localized: "welcome_name_placeholder", bundle: .app), text: $userName)
                        .textFieldStyle(RoundedTextFieldStyle(theme: theme))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier(AccessibilityID.userNameTextField)

                    Text("welcome_name_description", bundle: .app)
                        .font(theme.typography.captionSmall.font)
                        .foregroundColor(theme.colors.textTertiary.color)
                }
                .padding(.horizontal, theme.spacing.md)

                Spacer()

                // Continue button
                Button {
                    if isNameValid {
                        isLoading = true
                        let trimmedName = userName.trimmingCharacters(in: .whitespaces)
                        onComplete(trimmedName)
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("welcome_start", bundle: .app)
                    }
                }
                .buttonStyle(PrimaryButtonStyle(theme: theme))
                .disabled(!isNameValid || isLoading)
                .accessibilityIdentifier(AccessibilityID.startButton)
                .padding(.horizontal, theme.spacing.md)
                .padding(.bottom, theme.spacing.xl)
            }
        }
    }
}

// MARK: - Rounded Text Field Style

struct RoundedTextFieldStyle: TextFieldStyle {
    let theme: DesignSystem

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
            .font(theme.typography.bodyMedium.font)
    }
}

#Preview("WelcomeView_Okumuka") {
    WelcomeView_Okumuka { name in
        print("Name entered: \(name)")
    }
}

