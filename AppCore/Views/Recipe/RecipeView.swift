import SwiftUI

// MARK: - Accessibility Identifiers

enum RecipeAccessibilityID {
    static let loadingView = "recipe_view_loading"
    static let errorView = "recipe_view_error"
    static let errorRetryButton = "recipe_button_retry"
    static let recipeTitle = "recipe_text_title"
    static let recipeDescription = "recipe_text_description"
    static let ingredientsList = "recipe_list_ingredients"
    static func ingredientItem(_ index: Int) -> String { "recipe_button_ingredient_\(index)" }
    static let stepsList = "recipe_list_steps"
    static func stepItem(_ index: Int) -> String { "recipe_button_step_\(index)" }
    static let shoppingListButton = "recipe_button_shoppingList"
    static let modifiedBadge = "recipe_badge_modified"
}

// MARK: - RecipeView

struct RecipeView: View {
    private let ds = DesignSystem.default

    let recipe: Recipe?
    let isLoading: Bool
    let errorMessage: String?

    let onIngredientTapped: (Ingredient) -> Void
    let onStepTapped: (CookingStep) -> Void
    let onRetryTapped: () -> Void
    let onShoppingListTapped: () -> Void

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if let recipe = recipe {
                recipeContent(recipe)
            } else {
                emptyView
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        RecipeSkeletonView()
            .accessibilityIdentifier(RecipeAccessibilityID.loadingView)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: ds.spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(ds.colors.error.color)

            Text(message)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)

            Button(action: onRetryTapped) {
                Label(String(localized: "recipe_button_retry", bundle: .app), systemImage: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(ds.colors.primaryBrand.color)
            .accessibilityIdentifier(RecipeAccessibilityID.errorRetryButton)
        }
        .padding(ds.spacing.xl)
        .accessibilityIdentifier(RecipeAccessibilityID.errorView)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        Text("recipe_empty_message", bundle: .app)
            .font(.body)
            .foregroundColor(ds.colors.textSecondary.color)
    }

    // MARK: - Recipe Content

    private func recipeContent(_ recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ds.spacing.lg) {
                // Recipe Description
                if let description = recipe.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(ds.colors.textSecondary.color)
                        .accessibilityIdentifier(RecipeAccessibilityID.recipeDescription)
                }

                // Recipe Images
                if !recipe.imageURLs.isEmpty {
                    recipeImages(recipe.imageURLs)
                }

                // Ingredients Section
                ingredientsSection(recipe.ingredientsInfo)

                // Steps Section
                stepsSection(recipe.steps)
            }
            .padding(ds.spacing.md)
        }
        .navigationTitle(recipe.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onShoppingListTapped) {
                    Image(systemName: "cart")
                }
                .accessibilityIdentifier(RecipeAccessibilityID.shoppingListButton)
            }
        }
    }

    // MARK: - Recipe Images

    private func recipeImages(_ urls: [URL]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ds.spacing.sm) {
                ForEach(urls, id: \.self) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(ds.colors.backgroundSecondary.color)
                                .frame(width: 200, height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 150)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(ds.colors.backgroundSecondary.color)
                                .frame(width: 200, height: 150)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(ds.colors.textTertiary.color)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
                }
            }
        }
    }

    // MARK: - Ingredients Section

    private func ingredientsSection(_ ingredientsInfo: Ingredients) -> some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            HStack {
                Text("recipe_section_ingredients", bundle: .app)
                    .font(.headline)
                    .foregroundColor(ds.colors.textPrimary.color)

                if let servings = ingredientsInfo.servings {
                    Text("(\(servings))")
                        .font(.subheadline)
                        .foregroundColor(ds.colors.textSecondary.color)
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(ingredientsInfo.items.enumerated()), id: \.element.id) { index, ingredient in
                    ingredientRow(ingredient, index: index)

                    if index < ingredientsInfo.items.count - 1 {
                        Divider()
                            .background(ds.colors.separator.color)
                    }
                }
            }
            .background(ds.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            .accessibilityIdentifier(RecipeAccessibilityID.ingredientsList)
        }
    }

    private func ingredientRow(_ ingredient: Ingredient, index: Int) -> some View {
        Button(action: { onIngredientTapped(ingredient) }) {
            HStack {
                VStack(alignment: .leading, spacing: ds.spacing.xxs) {
                    Text(ingredient.name)
                        .font(.body)
                        .foregroundColor(ds.colors.textPrimary.color)

                    if let amount = ingredient.amount {
                        Text(amount)
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                    }
                }

                Spacer()

                if ingredient.isModified {
                    modifiedBadge
                } else {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)
                }
            }
            .padding(ds.spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(RecipeAccessibilityID.ingredientItem(index))
    }

    // MARK: - Steps Section

    private func stepsSection(_ steps: [CookingStep]) -> some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            Text("recipe_section_steps", bundle: .app)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            VStack(spacing: ds.spacing.sm) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    stepRow(step, index: index)
                }
            }
            .accessibilityIdentifier(RecipeAccessibilityID.stepsList)
        }
    }

    private func stepRow(_ step: CookingStep, index: Int) -> some View {
        Button(action: { onStepTapped(step) }) {
            VStack(alignment: .leading, spacing: ds.spacing.sm) {
                HStack(alignment: .top, spacing: ds.spacing.md) {
                    // Step number badge
                    Text("\(step.stepNumber)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(ds.colors.primaryBrand.color)
                        .clipShape(Circle())

                    Text(step.instruction)
                        .font(.body)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    if step.isModified {
                        modifiedBadge
                    } else {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .font(.caption)
                            .foregroundColor(ds.colors.textTertiary.color)
                    }
                }

                // Step images (full width)
                if !step.imageURLs.isEmpty {
                    stepImages(step.imageURLs)
                }
            }
            .padding(ds.spacing.md)
            .background(ds.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(RecipeAccessibilityID.stepItem(index))
    }

    private func stepImages(_ urls: [URL]) -> some View {
        VStack(spacing: ds.spacing.sm) {
            ForEach(urls, id: \.self) { url in
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(ds.colors.backgroundTertiary.color)
                            .aspectRatio(4 / 3, contentMode: .fit)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(4 / 3, contentMode: .fit)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(ds.colors.backgroundTertiary.color)
                            .aspectRatio(4 / 3, contentMode: .fit)
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
            }
        }
    }

    // MARK: - Modified Badge

    private var modifiedBadge: some View {
        Text("recipe_badge_modified_label", bundle: .app)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, ds.spacing.xs)
            .padding(.vertical, ds.spacing.xxs)
            .background(ds.colors.info.color)
            .clipShape(Capsule())
            .accessibilityIdentifier(RecipeAccessibilityID.modifiedBadge)
    }
}

// MARK: - Preview

#Preview("Loading") {
    NavigationStack {
        RecipeView(
            recipe: nil,
            isLoading: true,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {},
            onShoppingListTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("Error") {
    NavigationStack {
        RecipeView(
            recipe: nil,
            isLoading: false,
            errorMessage: String(localized: "recipe_error_load_failed", bundle: .app),
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {},
            onShoppingListTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("With Recipe") {
    NavigationStack {
        RecipeView(
            recipe: Recipe(
                title: "鶏の照り焼き",
                description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。ご飯のおかずにぴったりです。",
                imageURLs: [],
                ingredientsInfo: Ingredients(
                    servings: "2人分",
                    items: [
                        Ingredient(name: "鶏もも肉", amount: "2枚（500g）"),
                        Ingredient(name: "醤油", amount: "大さじ3"),
                        Ingredient(name: "みりん", amount: "大さじ2"),
                        Ingredient(name: "砂糖", amount: "大さじ1"),
                        Ingredient(name: "サラダ油", amount: "小さじ2", isModified: true)
                    ]
                ),
                steps: [
                    CookingStep(stepNumber: 1, instruction: "鶏もも肉を一口大に切る"),
                    CookingStep(stepNumber: 2, instruction: "フライパンに油を熱し、鶏肉を皮目から焼く", isModified: true),
                    CookingStep(stepNumber: 3, instruction: "両面に焼き色がついたら、醤油・みりん・砂糖を加える"),
                    CookingStep(stepNumber: 4, instruction: "タレを絡めながら照りが出るまで煮詰める")
                ]
            ),
            isLoading: false,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {},
            onShoppingListTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("With Recipe (No Description)") {
    NavigationStack {
        RecipeView(
            recipe: Recipe(
                title: "鶏の照り焼き",
                imageURLs: [],
                ingredientsInfo: Ingredients(
                    servings: "2人分",
                    items: [
                        Ingredient(name: "鶏もも肉", amount: "2枚（500g）"),
                        Ingredient(name: "醤油", amount: "大さじ3"),
                        Ingredient(name: "みりん", amount: "大さじ2"),
                        Ingredient(name: "砂糖", amount: "大さじ1"),
                        Ingredient(name: "サラダ油", amount: "小さじ2", isModified: true)
                    ]
                ),
                steps: [
                    CookingStep(stepNumber: 1, instruction: "鶏もも肉を一口大に切る"),
                    CookingStep(stepNumber: 2, instruction: "フライパンに油を熱し、鶏肉を皮目から焼く", isModified: true),
                    CookingStep(stepNumber: 3, instruction: "両面に焼き色がついたら、醤油・みりん・砂糖を加える"),
                    CookingStep(stepNumber: 4, instruction: "タレを絡めながら照りが出るまで煮詰める")
                ]
            ),
            isLoading: false,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {},
            onShoppingListTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("With Recipe (With Images)") {
    NavigationStack {
        RecipeView(
            recipe: Recipe(
                title: "鶏の照り焼き",
                description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。ご飯のおかずにぴったりです。",
                imageURLs: [
                    URL(string: "https://picsum.photos/seed/chicken-dish/200/150")!,
                    URL(string: "https://picsum.photos/seed/cooking-pan/200/150")!
                ],
                ingredientsInfo: Ingredients(
                    servings: "2人分",
                    items: [
                        Ingredient(name: "鶏もも肉", amount: "2枚（500g）"),
                        Ingredient(name: "醤油", amount: "大さじ3"),
                        Ingredient(name: "みりん", amount: "大さじ2"),
                        Ingredient(name: "砂糖", amount: "大さじ1"),
                        Ingredient(name: "サラダ油", amount: "小さじ2", isModified: true)
                    ]
                ),
                steps: [
                    CookingStep(
                        stepNumber: 1,
                        instruction: "鶏もも肉を一口大に切る",
                        imageURLs: [
                            URL(string: "https://picsum.photos/seed/cutting-board/400/300")!
                        ]
                    ),
                    CookingStep(
                        stepNumber: 2,
                        instruction: "フライパンに油を熱し、鶏肉を皮目から焼く",
                        imageURLs: [
                            URL(string: "https://picsum.photos/seed/frying-meat/400/300")!,
                            URL(string: "https://picsum.photos/seed/golden-brown/400/300")!
                        ],
                        isModified: true
                    ),
                    CookingStep(stepNumber: 3, instruction: "両面に焼き色がついたら、醤油・みりん・砂糖を加える"),
                    CookingStep(
                        stepNumber: 4,
                        instruction: "タレを絡めながら照りが出るまで煮詰める",
                        imageURLs: [
                            URL(string: "https://picsum.photos/seed/sauce-glaze/400/300")!
                        ]
                    )
                ]
            ),
            isLoading: false,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {},
            onShoppingListTapped: {}
        )
    }
    .prefireEnabled()
}
