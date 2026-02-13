import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum SelectedRecipesThumbnailBarAccessibilityID {
    static let bar = "selectedRecipesThumbnailBar"
    static func recipe(_ id: UUID) -> String { "selectedRecipesThumbnailBar_recipe_\(id.uuidString)" }
    static func remove(_ id: UUID) -> String { "selectedRecipesThumbnailBar_remove_\(id.uuidString)" }
}

// MARK: - SelectedRecipesThumbnailBar

/// 選択中のレシピをサムネイル表示する水平スクロールバー
///
/// 買い物リスト作成画面で、選択されたレシピをサムネイル画像とタイトルで表示する。
/// 各サムネイルには削除ボタンが付いており、選択を解除できる。
/// レシピが1件も選択されていない場合は何も表示しない。
struct SelectedRecipesThumbnailBar: View {
    private let ds = DesignSystem.default

    let selectedRecipes: [Recipe]
    let onRemoveTapped: (UUID) -> Void

    var body: some View {
        if !selectedRecipes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ds.spacing.sm) {
                    ForEach(selectedRecipes) { recipe in
                        recipeThumbnail(recipe)
                    }
                }
                .padding(.horizontal, ds.spacing.md)
                .padding(.vertical, ds.spacing.xs)
            }
            .accessibilityIdentifier(SelectedRecipesThumbnailBarAccessibilityID.bar)
        }
    }

    // MARK: - Recipe Thumbnail

    private func recipeThumbnail(_ recipe: Recipe) -> some View {
        VStack(spacing: ds.spacing.xxs) {
            RecipeImageView(
                source: recipe.imageURLs.first,
                size: 50,
                cornerRadius: ds.cornerRadius.xs,
                placeholderIconSize: 16
            )
            .overlay(alignment: .topTrailing) {
                removeButton(recipe.id)
            }
            .accessibilityIdentifier(SelectedRecipesThumbnailBarAccessibilityID.recipe(recipe.id))

            Text(recipe.title)
                .font(.caption2)
                .foregroundColor(ds.colors.textSecondary.color)
                .lineLimit(1)
                .frame(width: 50)
        }
    }

    // MARK: - Remove Button

    private func removeButton(_ recipeID: UUID) -> some View {
        Button {
            onRemoveTapped(recipeID)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    ds.colors.textTertiary.color,
                    ds.colors.backgroundPrimary.color
                )
        }
        .offset(x: 4, y: -4)
        .accessibilityIdentifier(SelectedRecipesThumbnailBarAccessibilityID.remove(recipeID))
    }
}

// MARK: - Preview

#Preview("ThumbnailBar Empty") {
    SelectedRecipesThumbnailBar(
        selectedRecipes: [],
        onRemoveTapped: { _ in }
    )
    .prefireEnabled()
}

#Preview("ThumbnailBar Single") {
    SelectedRecipesThumbnailBar(
        selectedRecipes: [
            Recipe(
                title: "鶏の照り焼き",
                imageURLs: [.previewPlaceholder()],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
        ],
        onRemoveTapped: { _ in }
    )
    .prefireEnabled()
}

#Preview("ThumbnailBar Multiple") {
    SelectedRecipesThumbnailBar(
        selectedRecipes: [
            Recipe(
                title: "鶏の照り焼き",
                imageURLs: [.previewPlaceholder()],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
            Recipe(
                title: "カレーライス",
                imageURLs: [.previewPlaceholder(color: .systemBrown)],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
            Recipe(
                title: "ミネストローネスープ",
                imageURLs: [.previewPlaceholder(color: .systemRed)],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
            Recipe(
                title: "サラダ",
                imageURLs: [],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
        ],
        onRemoveTapped: { _ in }
    )
    .prefireEnabled()
}
