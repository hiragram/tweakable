import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum RecipeHomeAccessibilityID {
    static let urlTextField = "recipeHome_textField_url"
    static let extractButton = "recipeHome_button_extract"
    static let clearButton = "recipeHome_button_clear"
    static let savedRecipesButton = "recipeHome_button_savedRecipes"
    static let shoppingListsButton = "recipeHome_button_shoppingLists"
}

// MARK: - RecipeHomeView

/// レシピURL入力画面
struct RecipeHomeView: View {
    private let ds = DesignSystem.default

    @Binding var urlText: String
    let isLoading: Bool
    let savedRecipesCount: Int
    let shoppingListsCount: Int
    let onExtractTapped: () -> Void
    let onSavedRecipesTapped: () -> Void
    let onShoppingListsTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: ds.spacing.xl) {
                Spacer()
                    .frame(height: ds.spacing.xl)

                // App icon / illustration
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(ds.colors.primaryBrand.color)

            // Title
            Text(.recipeHomeTitle)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(ds.colors.textPrimary.color)

            // Subtitle
            Text(.recipeHomeSubtitle)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ds.spacing.lg)

            // Saved Recipes Button
            if savedRecipesCount > 0 {
                Button(action: onSavedRecipesTapped) {
                    HStack(spacing: ds.spacing.sm) {
                        Image(systemName: "bookmark.fill")
                        Text(.savedRecipesButton)
                        Spacer()
                        Text("\(savedRecipesCount)")
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(ds.colors.textTertiary.color)
                    }
                    .padding(ds.spacing.md)
                    .background(ds.colors.backgroundSecondary.color)
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ds.spacing.lg)
                .accessibilityIdentifier(RecipeHomeAccessibilityID.savedRecipesButton)
            }

            // Shopping Lists Button
            Button(action: onShoppingListsTapped) {
                HStack(spacing: ds.spacing.sm) {
                    Image(systemName: "cart.fill")
                    Text(.shoppingListsTitle)
                    Spacer()
                    if shoppingListsCount > 0 {
                        Text("\(shoppingListsCount)")
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)
                }
                .padding(ds.spacing.md)
                .background(ds.colors.backgroundSecondary.color)
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, ds.spacing.lg)
            .accessibilityIdentifier(RecipeHomeAccessibilityID.shoppingListsButton)

                Spacer()
                    .frame(height: ds.spacing.xl)

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
                    .accessibilityIdentifier(RecipeHomeAccessibilityID.urlTextField)

                    if !urlText.isEmpty {
                        Button(action: { urlText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ds.colors.textTertiary.color)
                        }
                        .accessibilityIdentifier(RecipeHomeAccessibilityID.clearButton)
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
                .accessibilityIdentifier(RecipeHomeAccessibilityID.extractButton)
            }
            .padding(.horizontal, ds.spacing.lg)
            .padding(.bottom, ds.spacing.xl)
            }
        }
    }
}

// MARK: - Preview

#Preview("RecipeHome Empty") {
    RecipeHomeView(
        urlText: .constant(""),
        isLoading: false,
        savedRecipesCount: 0,
        shoppingListsCount: 0,
        onExtractTapped: {},
        onSavedRecipesTapped: {},
        onShoppingListsTapped: {}
    )
    .prefireEnabled()
}

#Preview("RecipeHome With URL") {
    RecipeHomeView(
        urlText: .constant("https://www.allrecipes.com/recipe/12345"),
        isLoading: false,
        savedRecipesCount: 0,
        shoppingListsCount: 0,
        onExtractTapped: {},
        onSavedRecipesTapped: {},
        onShoppingListsTapped: {}
    )
    .prefireEnabled()
}

#Preview("RecipeHome Loading") {
    RecipeHomeView(
        urlText: .constant("https://www.allrecipes.com/recipe/12345"),
        isLoading: true,
        savedRecipesCount: 0,
        shoppingListsCount: 0,
        onExtractTapped: {},
        onSavedRecipesTapped: {},
        onShoppingListsTapped: {}
    )
    .prefireEnabled()
}

#Preview("RecipeHome With Saved") {
    RecipeHomeView(
        urlText: .constant(""),
        isLoading: false,
        savedRecipesCount: 3,
        shoppingListsCount: 2,
        onExtractTapped: {},
        onSavedRecipesTapped: {},
        onShoppingListsTapped: {}
    )
    .prefireEnabled()
}
