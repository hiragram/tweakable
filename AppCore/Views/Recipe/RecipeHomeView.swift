import SwiftUI

// MARK: - Accessibility Identifiers

enum RecipeHomeAccessibilityID {
    static let urlTextField = "recipeHome_textField_url"
    static let extractButton = "recipeHome_button_extract"
    static let clearButton = "recipeHome_button_clear"
}

// MARK: - RecipeHomeView

/// レシピURL入力画面
struct RecipeHomeView: View {
    private let ds = DesignSystem.default

    @Binding var urlText: String
    let isLoading: Bool
    let onExtractTapped: () -> Void

    var body: some View {
        VStack(spacing: ds.spacing.xl) {
            Spacer()

            // App icon / illustration
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(ds.colors.primaryBrand.color)

            // Title
            Text("recipe_home_title", bundle: .app)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(ds.colors.textPrimary.color)

            // Subtitle
            Text("recipe_home_subtitle", bundle: .app)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ds.spacing.lg)

            Spacer()

            // URL input section
            VStack(spacing: ds.spacing.md) {
                HStack {
                    TextField(
                        String(localized: "recipe_home_url_placeholder", bundle: .app),
                        text: $urlText
                    )
                    .textFieldStyle(.plain)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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
                        Text("recipe_home_extract_button", bundle: .app)
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

// MARK: - Preview

#Preview("Empty") {
    RecipeHomeView(
        urlText: .constant(""),
        isLoading: false,
        onExtractTapped: {}
    )
}

#Preview("With URL") {
    RecipeHomeView(
        urlText: .constant("https://www.allrecipes.com/recipe/12345"),
        isLoading: false,
        onExtractTapped: {}
    )
}

#Preview("Loading") {
    RecipeHomeView(
        urlText: .constant("https://www.allrecipes.com/recipe/12345"),
        isLoading: true,
        onExtractTapped: {}
    )
}
