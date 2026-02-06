import NukeUI
import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum RecipeAccessibilityID {
    static let loadingView = "recipe_view_loading"
    static let errorView = "recipe_view_error"
    static let errorRetryButton = "recipe_button_retry"
    static let heroImage = "recipe_image_hero"
    static let recipeTitle = "recipe_text_title"
    static let recipeDescription = "recipe_text_description"
    static let ingredientsList = "recipe_list_ingredients"
    static func ingredientItem(_ index: Int) -> String { "recipe_button_ingredient_\(index)" }
    static let stepsList = "recipe_list_steps"
    static func stepItem(_ index: Int) -> String { "recipe_button_step_\(index)" }
    static let modifiedBadge = "recipe_badge_modified"
    static let sourceURLLink = "recipe_link_sourceURL"
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

    @State private var isTitleVisible: Bool = true

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
                Label(String(localized: .recipeButtonRetry), systemImage: "arrow.clockwise")
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
        Text(.recipeEmptyMessage)
            .font(.body)
            .foregroundColor(ds.colors.textSecondary.color)
    }

    // MARK: - Recipe Content

    /// レシピのメインコンテンツを表示
    ///
    /// スクロール位置に応じてナビゲーションタイトルを動的に切り替える。
    /// - ヒーロー画像表示中: タイトル非表示（画像内に料理名が見える想定）
    /// - スクロール後: ナビゲーションバーにタイトルを表示
    private func recipeContent(_ recipe: Recipe) -> some View {
        let hasHeroImage = recipe.imageURLs.first != nil

        return ScrollView {
            VStack(spacing: 0) {
                // Hero Image（画面幅いっぱい）
                if let firstImageURL = recipe.imageURLs.first {
                    heroImage(firstImageURL)
                }

                // Content area
                VStack(alignment: .leading, spacing: ds.spacing.lg) {
                    // Recipe Title
                    Text(recipe.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ds.colors.textPrimary.color)

                    // Recipe Description
                    if let description = recipe.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(ds.colors.textSecondary.color)
                            .accessibilityIdentifier(RecipeAccessibilityID.recipeDescription)
                    }

                    // Source URL Link
                    if let sourceURL = recipe.sourceURL {
                        Link(destination: sourceURL) {
                            HStack(spacing: ds.spacing.xs) {
                                Image(systemName: "safari.fill")
                                Text(.recipeViewOriginalLink)
                            }
                            .font(ds.typography.bodySmall.font)
                            .foregroundColor(ds.colors.primaryBrand.color)
                        }
                        .padding(.top, ds.spacing.xxs)
                        .accessibilityIdentifier(RecipeAccessibilityID.sourceURLLink)
                    }

                    // Ingredients Section
                    ingredientsSection(recipe.ingredientsInfo)

                    // Steps Section
                    stepsSection(recipe.steps)
                }
                .padding(.horizontal, ds.spacing.md)
                .padding(.vertical, ds.spacing.md)
                .frame(maxWidth: .infinity)
            }
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            // 280pt以上スクロールしたらナビゲーションタイトルを表示
            geometry.contentOffset.y > 280
        } action: { _, shouldShowNavTitle in
            isTitleVisible = !shouldShowNavTitle
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(isTitleVisible ? "" : recipe.title)
    }

    // MARK: - Hero Image

    private func heroImage(_ source: ImageSource) -> some View {
        Group {
            switch source {
            case .remote(let url):
                LazyImage(url: url) { state in
                    if state.isLoading {
                        Rectangle()
                            .fill(ds.colors.backgroundSecondary.color)
                            .frame(height: 300)
                            .overlay { ProgressView() }
                    } else if let image = state.image {
                        heroImageContent(image)
                    } else {
                        Rectangle()
                            .fill(ds.colors.backgroundSecondary.color)
                            .frame(height: 300)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(ds.colors.textTertiary.color)
                            }
                    }
                }
            case .local(let fileURL):
                if let data = try? Data(contentsOf: fileURL),
                   let uiImage = UIImage(data: data) {
                    heroImageContent(Image(uiImage: uiImage))
                }
            case .uiImage(let uiImage):
                heroImageContent(Image(uiImage: uiImage))
            }
        }
        .clipShape(RoundedCorner(radius: ds.cornerRadius.xl, corners: [.bottomLeft, .bottomRight]))
        .overlay(alignment: .top) {
            SmoothGradient(
                from: .clear,
                to: Color(uiColor: .systemBackground),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 60)
        }
        .accessibilityIdentifier(RecipeAccessibilityID.heroImage)
    }

    /// ブラー背景付きヒーロー画像
    private func heroImageContent(_ image: Image) -> some View {
        BlurredBackgroundImage(image: image, height: 300)
    }

    // MARK: - Ingredients Section

    private func ingredientsSection(_ ingredientsInfo: Ingredients) -> some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            HStack(spacing: ds.spacing.xs) {
                Image(systemName: "carrot.fill")
                    .font(.headline)
                    .foregroundColor(ds.colors.secondaryBrand.color)

                Text(.recipeSectionIngredients)
                    .font(.headline)
                    .foregroundColor(ds.colors.textPrimary.color)

                if let servings = ingredientsInfo.servings {
                    Text("(\(servings))")
                        .font(.subheadline)
                        .foregroundColor(ds.colors.textSecondary.color)
                }
            }

            VStack(spacing: 0) {
                ForEach(ingredientsInfo.items.indices, id: \.self) { index in
                    let ingredient = ingredientsInfo.items[index]
                    if index == 0 {
                        ingredientRow(ingredient, index: index)
                            .popoverTip(IngredientSubstitutionTip())
                    } else {
                        ingredientRow(ingredient, index: index)
                    }

                    if index < ingredientsInfo.items.count - 1 {
                        Divider()
                            .background(ds.colors.separator.color)
                    }
                }
            }
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
            .padding(.vertical, ds.spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(RecipeAccessibilityID.ingredientItem(index))
    }

    // MARK: - Steps Section

    private func stepsSection(_ steps: [CookingStep]) -> some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            HStack(spacing: ds.spacing.xs) {
                Image(systemName: "list.number")
                    .font(.headline)
                    .foregroundColor(ds.colors.secondaryBrand.color)

                Text(.recipeSectionSteps)
                    .font(.headline)
                    .foregroundColor(ds.colors.textPrimary.color)
            }

            VStack(spacing: ds.spacing.sm) {
                ForEach(steps.indices, id: \.self) { index in
                    let step = steps[index]
                    if index == 0 {
                        stepRow(step, index: index)
                            .popoverTip(StepSubstitutionTip())
                    } else {
                        stepRow(step, index: index)
                    }
                }
            }
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
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

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
            .padding(.vertical, ds.spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(RecipeAccessibilityID.stepItem(index))
    }

    private func stepImages(_ sources: [ImageSource]) -> some View {
        VStack(spacing: ds.spacing.sm) {
            ForEach(sources.indices, id: \.self) { index in
                let source = sources[index]
                Group {
                    switch source {
                    case .remote(let url):
                        LazyImage(url: url) { state in
                            if state.isLoading {
                                Rectangle()
                                    .fill(ds.colors.backgroundTertiary.color)
                                    .aspectRatio(4 / 3, contentMode: .fit)
                                    .overlay { ProgressView() }
                            } else if let image = state.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Rectangle()
                                    .fill(ds.colors.backgroundTertiary.color)
                                    .aspectRatio(4 / 3, contentMode: .fit)
                            }
                        }
                    case .local(let fileURL):
                        if let data = try? Data(contentsOf: fileURL),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    case .uiImage(let uiImage):
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Modified Badge

    private var modifiedBadge: some View {
        Text(.recipeBadgeModifiedLabel)
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
            onRetryTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("Error") {
    NavigationStack {
        RecipeView(
            recipe: nil,
            isLoading: false,
            errorMessage: String(localized: .recipeErrorLoadFailed),
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {}
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
            onRetryTapped: {}
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
            onRetryTapped: {}
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
                imageURLs: [.previewPlaceholder()],
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
                        imageURLs: [.previewPlaceholder()]
                    ),
                    CookingStep(
                        stepNumber: 2,
                        instruction: "フライパンに油を熱し、鶏肉を皮目から焼く",
                        imageURLs: [.previewPlaceholder()],
                        isModified: true
                    ),
                    CookingStep(stepNumber: 3, instruction: "両面に焼き色がついたら、醤油・みりん・砂糖を加える"),
                    CookingStep(
                        stepNumber: 4,
                        instruction: "タレを絡めながら照りが出るまで煮詰める",
                        imageURLs: [.previewPlaceholder()]
                    )
                ]
            ),
            isLoading: false,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("With Recipe (Remote Hero Image)") {
    NavigationStack {
        RecipeView(
            recipe: Recipe(
                title: "鶏の照り焼き",
                description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。ご飯のおかずにぴったりです。",
                imageURLs: [.remote(url: URL(string: "https://img-global-jp.cpcdn.com/recipes/a74bad56b72e6dab/1280x1280sq80/photo.webp")!)],
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
                        imageURLs: [.previewPlaceholder()]
                    ),
                    CookingStep(
                        stepNumber: 2,
                        instruction: "フライパンに油を熱し、鶏肉を皮目から焼く",
                        imageURLs: [.previewPlaceholder()],
                        isModified: true
                    ),
                    CookingStep(stepNumber: 3, instruction: "両面に焼き色がついたら、醤油・みりん・砂糖を加える"),
                    CookingStep(
                        stepNumber: 4,
                        instruction: "タレを絡めながら照りが出るまで煮詰める",
                        imageURLs: [.previewPlaceholder()]
                    )
                ]
            ),
            isLoading: false,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {}
        )
    }
}

#Preview("With Recipe (With Source URL)") {
    NavigationStack {
        RecipeView(
            recipe: Recipe(
                title: "鶏の照り焼き",
                description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。",
                imageURLs: [],
                ingredientsInfo: Ingredients(
                    servings: "2人分",
                    items: [
                        Ingredient(name: "鶏もも肉", amount: "2枚（500g）")
                    ]
                ),
                steps: [
                    CookingStep(stepNumber: 1, instruction: "鶏もも肉を一口大に切る")
                ],
                sourceURL: URL(string: "https://example.com/recipe")
            ),
            isLoading: false,
            errorMessage: nil,
            onIngredientTapped: { _ in },
            onStepTapped: { _ in },
            onRetryTapped: {}
        )
    }
    .prefireEnabled()
}

// MARK: - RoundedCorner Shape

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
