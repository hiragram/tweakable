import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum SubstitutionSheetAccessibilityID {
    static let sheetContainer = "substitutionSheet_container"
    static let promptTextField = "substitutionSheet_textField_prompt"
    static let submitButton = "substitutionSheet_button_submit"
    static let upgradeButton = "substitutionSheet_button_upgrade"
    static let loadingIndicator = "substitutionSheet_loading"
    static let errorText = "substitutionSheet_text_error"
    static let approveButton = "substitutionSheet_button_approve"
    static let rejectButton = "substitutionSheet_button_reject"
    static let requestMoreButton = "substitutionSheet_button_requestMore"
    static let additionalPromptTextField = "substitutionSheet_textField_additionalPrompt"
    static let sendMoreButton = "substitutionSheet_button_sendMore"
}

// MARK: - SubstitutionSheetView

struct SubstitutionSheetView: View {
    private let ds = DesignSystem.default

    let store: AppStore
    let target: SubstitutionTarget
    let isProcessing: Bool
    let isPremiumUser: Bool
    let errorMessage: String?

    // 新規追加: プレビューモード関連
    let sheetMode: SubstitutionSheetMode
    let previewRecipe: Recipe?
    let originalRecipe: Recipe?

    let onSubmit: (String) -> Void
    let onDismiss: () -> Void

    // 新規追加: 確認アクション
    let onApprove: () -> Void
    let onReject: () -> Void
    let onRequestMore: (String) -> Void

    @State private var promptText: String = ""
    @State private var additionalPromptText: String = ""
    @State private var showsAdditionalInput: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isAdditionalTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: ds.spacing.lg) {
                switch sheetMode {
                case .input:
                    inputModeContent
                case .preview:
                    previewModeContent
                }

                Spacer()
            }
            .padding(ds.spacing.md)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: .substitutionButtonCancel)) {
                        onDismiss()
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .sheet(isPresented: .init(
            get: { store.state.subscription.showsPaywall },
            set: { if !$0 { store.send(.subscription(.hidePaywall)) } }
        )) {
            PaywallContainerView(store: store)
        }
    }

    private var navigationTitle: String {
        switch sheetMode {
        case .input:
            return String(localized: .substitutionTitle)
        case .preview:
            return String(localized: .substitutionPreviewTitle)
        }
    }

    // MARK: - Input Mode Content

    private var inputModeContent: some View {
        VStack(spacing: ds.spacing.lg) {
            targetInfoSection

            if isPremiumUser {
                premiumUserContent
            } else {
                freeUserContent
            }
        }
    }

    // MARK: - Preview Mode Content

    private var previewModeContent: some View {
        VStack(spacing: ds.spacing.lg) {
            // 差分表示セクション
            diffDisplaySection

            // 追加指示入力欄（showsAdditionalInputがtrueの時のみ）
            if showsAdditionalInput {
                additionalInputSection
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(ds.colors.error.color)
                    .accessibilityIdentifier(SubstitutionSheetAccessibilityID.errorText)
            }

            // アクションボタン
            previewActionButtons
        }
    }

    // MARK: - Diff Display Section

    private var diffDisplaySection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ds.spacing.md) {
                // 変更された食材
                let ingredientDiffs = modifiedIngredients
                if !ingredientDiffs.isEmpty {
                    Text(.substitutionSectionIngredients)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)

                    ForEach(ingredientDiffs, id: \.new.id) { original, new in
                        DiffItemView(
                            beforeText: formatIngredient(original),
                            afterText: formatIngredient(new)
                        )
                    }
                }

                // 変更された工程
                let stepDiffs = modifiedSteps
                if !stepDiffs.isEmpty {
                    Text(.substitutionSectionSteps)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .padding(.top, ingredientDiffs.isEmpty ? 0 : ds.spacing.md)

                    ForEach(stepDiffs, id: \.new.id) { original, new in
                        DiffItemView(
                            beforeText: "\(original.stepNumber). \(original.instruction)",
                            afterText: "\(new.stepNumber). \(new.instruction)"
                        )
                    }
                }

                // 新規追加された食材
                let addedIngredients = self.addedIngredients
                if !addedIngredients.isEmpty {
                    Text(.substitutionSectionAddedIngredients)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .padding(.top, (ingredientDiffs.isEmpty && stepDiffs.isEmpty) ? 0 : ds.spacing.md)

                    ForEach(addedIngredients, id: \.id) { ingredient in
                        AddedItemView(text: formatIngredient(ingredient))
                    }
                }

                // 新規追加された工程
                let addedSteps = self.addedSteps
                if !addedSteps.isEmpty {
                    Text(.substitutionSectionAddedSteps)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .padding(.top, addedIngredients.isEmpty ? ds.spacing.md : 0)

                    ForEach(addedSteps, id: \.id) { step in
                        AddedItemView(text: "\(step.stepNumber). \(step.instruction)")
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Diff Helpers

    private var modifiedIngredients: [(original: Ingredient, new: Ingredient)] {
        guard let preview = previewRecipe,
              let original = originalRecipe else { return [] }

        return preview.ingredientsInfo.allItems
            .filter { $0.isModified }
            .compactMap { newIngredient in
                guard let originalIngredient = original.ingredientsInfo.allItems.first(where: { $0.id == newIngredient.id }) else {
                    return nil
                }
                return (original: originalIngredient, new: newIngredient)
            }
    }

    private var modifiedSteps: [(original: CookingStep, new: CookingStep)] {
        guard let preview = previewRecipe,
              let original = originalRecipe else { return [] }

        return preview.allSteps
            .filter { $0.isModified }
            .compactMap { newStep in
                guard let originalStep = original.allSteps.first(where: { $0.id == newStep.id }) else {
                    return nil
                }
                return (original: originalStep, new: newStep)
            }
    }

    private var addedIngredients: [Ingredient] {
        guard let preview = previewRecipe,
              let original = originalRecipe else { return [] }

        let originalIDs = Set(original.ingredientsInfo.allItems.map { $0.id })
        return preview.ingredientsInfo.allItems.filter { !originalIDs.contains($0.id) }
    }

    private var addedSteps: [CookingStep] {
        guard let preview = previewRecipe,
              let original = originalRecipe else { return [] }

        let originalIDs = Set(original.allSteps.map { $0.id })
        return preview.allSteps.filter { !originalIDs.contains($0.id) }
    }

    private func formatIngredient(_ ingredient: Ingredient) -> String {
        if let amount = ingredient.amount {
            return "\(ingredient.name) (\(amount))"
        }
        return ingredient.name
    }

    // MARK: - Additional Input Section

    private var additionalInputSection: some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            Text(.substitutionAdditionalPromptLabel)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            TextEditor(text: $additionalPromptText)
                .frame(minHeight: 60, maxHeight: 100)
                .padding(4)
                .background(ds.colors.backgroundSecondary.color)
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: ds.cornerRadius.sm)
                        .stroke(ds.colors.textTertiary.color.opacity(0.3), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if additionalPromptText.isEmpty {
                        Text(.substitutionAdditionalPlaceholder)
                            .foregroundColor(ds.colors.textTertiary.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                }
                .focused($isAdditionalTextFieldFocused)
                .disabled(isProcessing)
                .accessibilityIdentifier(SubstitutionSheetAccessibilityID.additionalPromptTextField)

            Button(action: {
                onRequestMore(additionalPromptText)
                additionalPromptText = ""
            }) {
                if isProcessing {
                    HStack(spacing: ds.spacing.sm) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text(.substitutionProcessing)
                    }
                } else {
                    Text(.substitutionButtonSendMore)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ds.spacing.sm)
            .foregroundColor(.white)
            .background(
                additionalPromptText.isEmpty || isProcessing
                    ? ds.colors.textTertiary.color
                    : ds.colors.primaryBrand.color
            )
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            .disabled(additionalPromptText.isEmpty || isProcessing)
            .accessibilityIdentifier(SubstitutionSheetAccessibilityID.sendMoreButton)
        }
        .onAppear {
            isAdditionalTextFieldFocused = true
        }
    }

    // MARK: - Preview Action Buttons

    private var previewActionButtons: some View {
        VStack(spacing: ds.spacing.sm) {
            // これでOK（プライマリ）
            Button(action: onApprove) {
                Text(.substitutionButtonApprove)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isProcessing)
            .accessibilityIdentifier(SubstitutionSheetAccessibilityID.approveButton)

            // やっぱりやめる / 修正させる（セカンダリ、横並び）
            HStack(spacing: ds.spacing.sm) {
                Button(action: onReject) {
                    Text(.substitutionButtonReject)
                }
                .buttonStyle(FilledSecondaryButtonStyle())
                .disabled(isProcessing)
                .accessibilityIdentifier(SubstitutionSheetAccessibilityID.rejectButton)

                Button(action: {
                    withAnimation {
                        showsAdditionalInput = true
                    }
                }) {
                    Text(.substitutionButtonRequestMore)
                }
                .buttonStyle(FilledSecondaryButtonStyle())
                .disabled(isProcessing || showsAdditionalInput)
                .accessibilityIdentifier(SubstitutionSheetAccessibilityID.requestMoreButton)
            }
        }
    }

    // MARK: - Target Info

    private var targetInfoSection: some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            Text(.substitutionSectionTarget)
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
                Text(.substitutionPromptLabel)
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
                            Text(.substitutionPlaceholder)
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
                        Text(.substitutionProcessing)
                    }
                } else {
                    Text(.substitutionButtonSubmit)
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

                Text(.substitutionPremiumTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ds.colors.textPrimary.color)

                Text(.substitutionPremiumDescription)
                    .font(.body)
                    .foregroundColor(ds.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }

            Button(action: { store.send(.subscription(.showPaywall)) }) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text(.substitutionButtonUpgrade)
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

// MARK: - Diff Item View

private struct DiffItemView: View {
    private let ds = DesignSystem.default

    let beforeText: String
    let afterText: String

    var body: some View {
        VStack(alignment: .leading, spacing: ds.spacing.xs) {
            HStack(spacing: ds.spacing.sm) {
                Text(.substitutionChangeBefore)
                    .font(.caption)
                    .foregroundColor(ds.colors.textTertiary.color)
                Text(beforeText)
                    .font(.body)
                    .strikethrough()
                    .foregroundColor(ds.colors.textSecondary.color)
            }

            HStack(spacing: ds.spacing.sm) {
                Text(.substitutionChangeAfter)
                    .font(.caption)
                    .foregroundColor(ds.colors.primaryBrand.color)
                Text(afterText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(ds.colors.textPrimary.color)
            }
        }
        .padding(ds.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ds.colors.backgroundSecondary.color)
        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
    }
}

// MARK: - Added Item View

private struct AddedItemView: View {
    private let ds = DesignSystem.default

    let text: String

    var body: some View {
        HStack(spacing: ds.spacing.sm) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(ds.colors.success.color)
            Text(text)
                .font(.body)
                .foregroundColor(ds.colors.textPrimary.color)
        }
        .padding(ds.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ds.colors.backgroundSecondary.color)
        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
    }
}

// MARK: - Preview

#Preview("Input Mode - Premium - Ingredient") {
    SubstitutionSheetView(
        store: AppStore(),
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: nil,
        sheetMode: .input,
        previewRecipe: nil,
        originalRecipe: nil,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}

#Preview("Input Mode - Premium - Step") {
    SubstitutionSheetView(
        store: AppStore(),
        target: .step(CookingStep(stepNumber: 2, instruction: "フライパンに油を熱し、鶏肉を皮目から焼く")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: nil,
        sheetMode: .input,
        previewRecipe: nil,
        originalRecipe: nil,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}

#Preview("Input Mode - Processing") {
    SubstitutionSheetView(
        store: AppStore(),
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: true,
        isPremiumUser: true,
        errorMessage: nil,
        sheetMode: .input,
        previewRecipe: nil,
        originalRecipe: nil,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}

#Preview("Input Mode - Error") {
    SubstitutionSheetView(
        store: AppStore(),
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: String(localized: .substitutionErrorFailed),
        sheetMode: .input,
        previewRecipe: nil,
        originalRecipe: nil,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}

#Preview("Input Mode - Free User") {
    SubstitutionSheetView(
        store: AppStore(),
        target: .ingredient(Ingredient(name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: false,
        errorMessage: nil,
        sheetMode: .input,
        previewRecipe: nil,
        originalRecipe: nil,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}

#Preview("Preview Mode - Ingredient") {
    let originalID = UUID()
    let original = Recipe(
        title: "唐揚げ",
        ingredientsInfo: Ingredients(
            servings: "2人分",
            sections: [
                IngredientSection(items: [
                    Ingredient(id: originalID, name: "鶏肉", amount: "200g"),
                    Ingredient(name: "塩", amount: "少々")
                ])
            ]
        ),
        stepSections: [
            CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "鶏肉を一口大に切る"),
                CookingStep(stepNumber: 2, instruction: "塩をふる")
            ])
        ]
    )
    let preview = Recipe(
        title: "唐揚げ",
        ingredientsInfo: Ingredients(
            servings: "2人分",
            sections: [
                IngredientSection(items: [
                    Ingredient(id: originalID, name: "豚肉", amount: "200g", isModified: true),
                    Ingredient(name: "塩", amount: "少々")
                ])
            ]
        ),
        stepSections: [
            CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "豚肉を一口大に切る", isModified: true),
                CookingStep(stepNumber: 2, instruction: "塩をふる")
            ])
        ]
    )

    return SubstitutionSheetView(
        store: AppStore(),
        target: .ingredient(Ingredient(id: originalID, name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: nil,
        sheetMode: .preview,
        previewRecipe: preview,
        originalRecipe: original,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}

#Preview("Preview Mode - With Additional Input") {
    let originalID = UUID()
    let original = Recipe(
        title: "唐揚げ",
        ingredientsInfo: Ingredients(
            servings: "2人分",
            sections: [
                IngredientSection(items: [Ingredient(id: originalID, name: "鶏肉", amount: "200g")])
            ]
        ),
        stepSections: []
    )
    let preview = Recipe(
        title: "唐揚げ",
        ingredientsInfo: Ingredients(
            servings: "2人分",
            sections: [
                IngredientSection(items: [Ingredient(id: originalID, name: "豚肉", amount: "200g", isModified: true)])
            ]
        ),
        stepSections: []
    )

    return SubstitutionSheetView(
        store: AppStore(),
        target: .ingredient(Ingredient(id: originalID, name: "鶏肉", amount: "200g")),
        isProcessing: false,
        isPremiumUser: true,
        errorMessage: nil,
        sheetMode: .preview,
        previewRecipe: preview,
        originalRecipe: original,
        onSubmit: { _ in },
        onDismiss: {},
        onApprove: {},
        onReject: {},
        onRequestMore: { _ in }
    )
    .prefireEnabled()
}
