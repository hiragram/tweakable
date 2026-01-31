import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum SavedRecipesListAccessibilityID {
    static let emptyView = "savedRecipesList_view_empty"
    static let list = "savedRecipesList_list"
    static func recipeRow(_ id: UUID) -> String { "savedRecipesList_button_recipe_\(id.uuidString)" }
    static func deleteButton(_ id: UUID) -> String { "savedRecipesList_button_delete_\(id.uuidString)" }
}

// MARK: - SavedRecipesListView

/// 保存済みレシピ一覧画面
struct SavedRecipesListView: View {
    private let ds = DesignSystem.default

    let recipes: [Recipe]
    let isLoading: Bool
    let onRecipeTapped: (Recipe) -> Void
    let onDeleteTapped: (UUID) -> Void

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if recipes.isEmpty {
                emptyView
            } else {
                recipeListView
            }
        }
        .navigationTitle(String(localized: "saved_recipes_title", bundle: .app))
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ProgressView()
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: ds.spacing.lg) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 48))
                .foregroundColor(ds.colors.textTertiary.color)

            Text("saved_recipes_empty_title", bundle: .app)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            Text("saved_recipes_empty_message", bundle: .app)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
        }
        .padding(ds.spacing.xl)
        .accessibilityIdentifier(SavedRecipesListAccessibilityID.emptyView)
    }

    // MARK: - Recipe List View

    private var recipeListView: some View {
        List {
            ForEach(recipes) { recipe in
                recipeRow(recipe)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    onDeleteTapped(recipes[index].id)
                }
            }
        }
        .listStyle(.plain)
        .accessibilityIdentifier(SavedRecipesListAccessibilityID.list)
    }

    private func recipeRow(_ recipe: Recipe) -> some View {
        Button(action: { onRecipeTapped(recipe) }) {
            HStack(spacing: ds.spacing.md) {
                // Recipe thumbnail
                recipeImage(recipe.imageURLs.first)

                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .lineLimit(2)

                    if let description = recipe.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                            .lineLimit(2)
                    }

                    HStack(spacing: ds.spacing.sm) {
                        Label(
                            "\(recipe.ingredientsInfo.items.count)",
                            systemImage: "carrot.fill"
                        )
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)

                        Label(
                            "\(recipe.steps.count)",
                            systemImage: "list.number"
                        )
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ds.colors.textTertiary.color)
            }
            .padding(.vertical, ds.spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(SavedRecipesListAccessibilityID.recipeRow(recipe.id))
    }

    private func recipeImage(_ source: ImageSource?) -> some View {
        Group {
            if let source = source {
                switch source {
                case .remote(let url):
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            placeholderImage
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                case .local(let fileURL):
                    if let data = try? Data(contentsOf: fileURL),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderImage
                    }
                case .uiImage(let uiImage):
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(ds.colors.backgroundSecondary.color)
            .overlay {
                Image(systemName: "fork.knife")
                    .foregroundColor(ds.colors.textTertiary.color)
            }
    }
}

// MARK: - Preview

#Preview("SavedRecipes Empty") {
    NavigationStack {
        SavedRecipesListView(
            recipes: [],
            isLoading: false,
            onRecipeTapped: { _ in },
            onDeleteTapped: { _ in }
        )
    }
    .prefireEnabled()
}

#Preview("SavedRecipes Loading") {
    NavigationStack {
        SavedRecipesListView(
            recipes: [],
            isLoading: true,
            onRecipeTapped: { _ in },
            onDeleteTapped: { _ in }
        )
    }
    .prefireEnabled()
}

#Preview("SavedRecipes With Recipes") {
    NavigationStack {
        SavedRecipesListView(
            recipes: [
                Recipe(
                    title: "鶏の照り焼き",
                    description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。",
                    imageURLs: [],
                    ingredientsInfo: Ingredients(
                        servings: "2人分",
                        items: [
                            Ingredient(name: "鶏もも肉", amount: "2枚"),
                            Ingredient(name: "醤油", amount: "大さじ3"),
                            Ingredient(name: "みりん", amount: "大さじ2")
                        ]
                    ),
                    steps: [
                        CookingStep(stepNumber: 1, instruction: "鶏もも肉を切る"),
                        CookingStep(stepNumber: 2, instruction: "焼く")
                    ]
                ),
                Recipe(
                    title: "カレーライス",
                    description: "家庭の定番カレー",
                    imageURLs: [],
                    ingredientsInfo: Ingredients(
                        servings: "4人分",
                        items: [
                            Ingredient(name: "豚肉", amount: "300g"),
                            Ingredient(name: "玉ねぎ", amount: "2個"),
                            Ingredient(name: "人参", amount: "1本"),
                            Ingredient(name: "じゃがいも", amount: "2個"),
                            Ingredient(name: "カレールー", amount: "1箱")
                        ]
                    ),
                    steps: [
                        CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                        CookingStep(stepNumber: 2, instruction: "肉を炒める"),
                        CookingStep(stepNumber: 3, instruction: "野菜を加えて煮込む"),
                        CookingStep(stepNumber: 4, instruction: "ルーを溶かす")
                    ]
                )
            ],
            isLoading: false,
            onRecipeTapped: { _ in },
            onDeleteTapped: { _ in }
        )
    }
    .prefireEnabled()
}
