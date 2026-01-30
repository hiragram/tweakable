import SwiftUI

// MARK: - Accessibility Identifiers

enum SubstitutionSheetAccessibilityID {
    static let sheetContainer = "substitutionSheet_container"
    static let promptTextField = "substitutionSheet_textField_prompt"
    static let submitButton = "substitutionSheet_button_submit"
    static let upgradeButton = "substitutionSheet_button_upgrade"
    static let loadingIndicator = "substitutionSheet_loading"
    static let errorText = "substitutionSheet_text_error"
}

// MARK: - SubstitutionSheetView

struct SubstitutionSheetView: View {
    private let ds = DesignSystem.default

    let target: SubstitutionTarget
    let isProcessing: Bool
    let isPremiumUser: Bool
    let errorMessage: String?

    let onSubmit: (String) -> Void
    let onUpgradeTapped: () -> Void
    let onDismiss: () -> Void

    @State private var promptText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: ds.spacing.lg) {
                // Target info
                targetInfoSection

                if isPremiumUser {
                    premiumUserContent
                } else {
                    freeUserContent
                }

                Spacer()
            }
            .padding(ds.spacing.md)
            .navigationTitle(String(localized: "substitution_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "substitution_button_cancel", bundle: .app)) {
                        onDismiss()
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }

    // MARK: - Target Info

    private var targetInfoSection: some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            Text("substitution_section_target", bundle: .app)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            Group {
                switch target {
                case .ingredient(let ingredient):
                    HStack {
                        Text(ingredient.name)
                            .font(.body)
                        if let amount = ingredient.amount {
                            Text("(\(amount))")
                                .font(.subheadline)
                                .foregroundColor(ds.colors.textSecondary.color)
                        }
                    }
                case .step(let step):
                    HStack(alignment: .top, spacing: ds.spacing.sm) {
                        Text("\(step.stepNumber).")
                            .font(.headline)
                            .foregroundColor(ds.colors.primaryBrand.color)
                        Text(step.instruction)
                            .font(.body)
                    }
                }
            }
            .padding(ds.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ds.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
        }
    }

    // MARK: - Premium User Content

    private var premiumUserContent: some View {
        VStack(spacing: ds.spacing.md) {
            VStack(alignment: .leading, spacing: ds.spacing.sm) {
                Text("substitution_prompt_label", bundle: .app)
                    .font(.headline)
                    .foregroundColor(ds.colors.textPrimary.color)

                TextEditor(text: $promptText)
                    .frame(minHeight: 80, maxHeight: 150)
                    .padding(4)
                    .background(ds.colors.backgroundSecondary.color)
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: ds.cornerRadius.sm)
                            .stroke(ds.colors.textTertiary.color.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if promptText.isEmpty {
                            Text("substitution_placeholder", bundle: .app)
                                .foregroundColor(ds.colors.textTertiary.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                    .focused($isTextFieldFocused)
                    .disabled(isProcessing)
                    .accessibilityIdentifier(SubstitutionSheetAccessibilityID.promptTextField)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(ds.colors.error.color)
                    .accessibilityIdentifier(SubstitutionSheetAccessibilityID.errorText)
            }

            Button(action: {
                onSubmit(promptText)
            }) {
                if isProcessing {
                    HStack(spacing: ds.spacing.sm) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .accessibilityIdentifier(SubstitutionSheetAccessibilityID.loadingIndicator)
                        Text("substitution_processing", bundle: .app)
                    }
                } else {
                    Text("substitution_button_submit", bundle: .app)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ds.spacing.sm)
            .foregroundColor(.white)
            .background(
                promptText.isEmpty || isProcessing
                    ? ds.colors.textTertiary.color
                    : ds.colors.primaryBrand.color
            )
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            .disabled(promptText.isEmpty || isProcessing)
            .accessibilityIdentifier(SubstitutionSheetAccessibilityID.submitButton)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }

    // MARK: - Free User Content

    private var freeUserContent: some View {
        VStack(spacing: ds.spacing.lg) {
            VStack(spacing: ds.spacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(ds.colors.primaryBrand.color)

                Text("substitution_premium_title", bundle: .app)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ds.colors.textPrimary.color)

                Text("substitution_premium_description", bundle: .app)
                    .font(.body)
                    .foregroundColor(ds.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }

            Button(action: onUpgradeTapped) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("substitution_button_upgrade", bundle: .app)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ds.spacing.sm)
                .foregroundColor(.white)
                .background(ds.colors.primaryBrand.color)
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            }
            .accessibilityIdentifier(SubstitutionSheetAccessibilityID.upgradeButton)
        }
        .padding(ds.spacing.md)
    }
}

// MARK: - Preview

#Preview("Premium - Ingredient") {
    SubstitutionSheetView(
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: nil,
        onSubmit: { _ in },
        onUpgradeTapped: {},
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("Premium - Step") {
    SubstitutionSheetView(
        target: .step(CookingStep(stepNumber: 2, instruction: "フライパンに油を熱し、鶏肉を皮目から焼く")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: nil,
        onSubmit: { _ in },
        onUpgradeTapped: {},
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("Premium - Processing") {
    SubstitutionSheetView(
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: true,
        isPremiumUser: true,
        errorMessage: nil,
        onSubmit: { _ in },
        onUpgradeTapped: {},
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("Premium - Error") {
    SubstitutionSheetView(
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: String(localized: "substitution_error_failed", bundle: .app),
        onSubmit: { _ in },
        onUpgradeTapped: {},
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("Free User") {
    SubstitutionSheetView(
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: false,
        errorMessage: nil,
        onSubmit: { _ in },
        onUpgradeTapped: {},
        onDismiss: {}
    )
    .prefireEnabled()
}
