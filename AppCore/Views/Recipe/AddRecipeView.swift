import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum AddRecipeAccessibilityID {
    static let urlTextField = "addRecipe_textField_url"
    static let extractButton = "addRecipe_button_extract"
    static let clearButton = "addRecipe_button_clear"
    static let closeButton = "addRecipe_button_close"
}

// MARK: - AddRecipeView

/// レシピURL入力画面（シートとして表示）
struct AddRecipeView: View {
    private let ds = DesignSystem.default

    @Binding var urlText: String
    let isLoading: Bool
    let onExtractTapped: () -> Void
    let onCloseTapped: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: ds.spacing.xl) {
                Spacer()
                    .frame(height: ds.spacing.xl)

                // Icon
                Image(systemName: "link.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(ds.colors.primaryBrand.color)

                // Title
                Text(.addRecipeTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ds.colors.textPrimary.color)

                // Subtitle
                Text(.addRecipeSubtitle)
                    .font(.body)
                    .foregroundColor(ds.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ds.spacing.lg)

                Spacer()

                // URL input section
                VStack(spacing: ds.spacing.md) {
                    HStack {
                        TextField(
                            String(localized: .recipeHomeUrlPlaceholder),
                            text: $urlText
                        )
                        .textFieldStyle(.plain)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isLoading)
                        .onSubmit {
                            if !urlText.isEmpty && !isLoading {
                                onExtractTapped()
                            }
                        }
                        .accessibilityIdentifier(AddRecipeAccessibilityID.urlTextField)

                        if !urlText.isEmpty {
                            Button(action: { urlText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(ds.colors.textTertiary.color)
                            }
                            .accessibilityIdentifier(AddRecipeAccessibilityID.clearButton)
                        }
                    }
                    .padding(ds.spacing.md)
                    .background(ds.colors.backgroundSecondary.color)
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))

                    Button(action: onExtractTapped) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(.recipeHomeExtractButton)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(ds.spacing.md)
                        .background(
                            urlText.isEmpty || isLoading
                                ? ds.colors.primaryBrand.color.opacity(0.5)
                                : ds.colors.primaryBrand.color
                        )
                        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
                    }
                    .disabled(urlText.isEmpty || isLoading)
                    .accessibilityIdentifier(AddRecipeAccessibilityID.extractButton)
                }
                .padding(.horizontal, ds.spacing.lg)
                .padding(.bottom, ds.spacing.xl)
            }
            .navigationTitle(String(localized: .addRecipeNavigationTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onCloseTapped) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityIdentifier(AddRecipeAccessibilityID.closeButton)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("AddRecipe Empty") {
    AddRecipeView(
        urlText: .constant(""),
        isLoading: false,
        onExtractTapped: {},
        onCloseTapped: {}
    )
    .prefireEnabled()
}

#Preview("AddRecipe With URL") {
    AddRecipeView(
        urlText: .constant("https://www.allrecipes.com/recipe/12345"),
        isLoading: false,
        onExtractTapped: {},
        onCloseTapped: {}
    )
    .prefireEnabled()
}

#Preview("AddRecipe Loading") {
    AddRecipeView(
        urlText: .constant("https://www.allrecipes.com/recipe/12345"),
        isLoading: true,
        onExtractTapped: {},
        onCloseTapped: {}
    )
    .prefireEnabled()
}
