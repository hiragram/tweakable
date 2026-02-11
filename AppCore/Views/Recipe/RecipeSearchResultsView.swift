import NukeUI
import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum RecipeSearchResultsAccessibilityID {
    static let emptyView = "searchResults_view_empty"
    static let list = "searchResults_list"
    static let categoryAll = "searchResults_button_categoryAll"
    static func categoryChip(_ id: UUID) -> String { "searchResults_button_category_\(id.uuidString)" }
    static func recipeRow(_ id: UUID) -> String { "searchResults_button_recipe_\(id.uuidString)" }
}

// MARK: - RecipeSearchResultsView

/// 検索結果画面（プレゼンテーション層）
struct RecipeSearchResultsView: View {
    private let ds = DesignSystem.default

    let results: [RecipeSearchResult]
    let categories: [RecipeCategory]
    let selectedCategoryID: UUID?
    let categoryCounts: [UUID: Int]
    let totalCount: Int
    let onRecipeTapped: (Recipe) -> Void
    let onCategoryTapped: (UUID?) -> Void

    var body: some View {
        Group {
            if results.isEmpty && totalCount == 0 {
                emptyView
            } else {
                resultListView
            }
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: ds.spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(ds.colors.textTertiary.color)

            Text(.searchResultsEmptyTitle)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            Text(.searchResultsEmptyMessage)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
        }
        .padding(ds.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier(RecipeSearchResultsAccessibilityID.emptyView)
    }

    // MARK: - Result List View

    private var resultListView: some View {
        ScrollView {
            VStack(spacing: ds.spacing.sm) {
                if !categories.isEmpty {
                    categoryChipsView
                }

                if results.isEmpty {
                    // カテゴリフィルタで結果が0件の場合
                    emptyView
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            searchResultRow(result)
                            if result.id != results.last?.id {
                                Divider()
                                    .padding(.leading, 60 + ds.spacing.md * 2)
                            }
                        }
                    }
                    .padding(.horizontal, ds.spacing.md)
                }
            }
        }
        .accessibilityIdentifier(RecipeSearchResultsAccessibilityID.list)
    }

    // MARK: - Category Chips

    private var categoryChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ds.spacing.xs) {
                categoryChipWithCount(
                    label: String(localized: .searchResultsCategoryAll),
                    count: totalCount,
                    isSelected: selectedCategoryID == nil,
                    accessibilityID: RecipeSearchResultsAccessibilityID.categoryAll
                ) {
                    onCategoryTapped(nil)
                }

                ForEach(categories) { category in
                    categoryChipWithCount(
                        label: category.name,
                        count: categoryCounts[category.id] ?? 0,
                        isSelected: selectedCategoryID == category.id,
                        accessibilityID: RecipeSearchResultsAccessibilityID.categoryChip(category.id)
                    ) {
                        onCategoryTapped(category.id)
                    }
                }
            }
            .padding(.horizontal, ds.spacing.md)
        }
    }

    private func categoryChipWithCount(
        label: String,
        count: Int,
        isSelected: Bool,
        accessibilityID: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text("\(label)(\(count))")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : ds.colors.textPrimary.color)
                .padding(.horizontal, ds.spacing.sm)
                .padding(.vertical, ds.spacing.xs)
                .background(isSelected ? ds.colors.primaryBrand.color : ds.colors.backgroundSecondary.color)
                .clipShape(Capsule())
        }
        .frame(minHeight: 44)
        .contentShape(Capsule())
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Search Result Row

    private func searchResultRow(_ result: RecipeSearchResult) -> some View {
        Button(action: { onRecipeTapped(result.recipe) }) {
            HStack(alignment: .top, spacing: ds.spacing.md) {
                recipeImage(result.recipe.imageURLs.first)

                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(result.recipe.title)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .lineLimit(1)

                    if let description = result.recipe.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                            .lineLimit(1)
                    }

                    matchBadgesView(result.matchFields)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ds.colors.textTertiary.color)
            }
            .padding(.vertical, ds.spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(RecipeSearchResultsAccessibilityID.recipeRow(result.recipe.id))
    }

    // MARK: - Match Badges

    private func matchBadgesView(_ matchFields: SearchMatchField) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if matchFields.contains(.title) {
                matchIndicator(String(localized: .searchResultsMatchTitle))
            }
            if matchFields.contains(.description) {
                matchIndicator(String(localized: .searchResultsMatchDescription))
            }
            if matchFields.contains(.ingredients) {
                matchIndicator(String(localized: .searchResultsMatchIngredients))
            }
            if matchFields.contains(.steps) {
                matchIndicator(String(localized: .searchResultsMatchSteps))
            }
        }
    }

    private func matchIndicator(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(ds.colors.textTertiary.color)
    }

    // MARK: - Recipe Image

    private func recipeImage(_ source: ImageSource?) -> some View {
        Group {
            if let source = source {
                switch source {
                case .remote(let url):
                    LazyImage(url: url) { state in
                        if state.isLoading {
                            placeholderImage
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                }
                        } else if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
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
                case .bundled(let name):
                    if let uiImage = UIImage(named: name, in: .app, with: nil) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderImage
                    }
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

// MARK: - Preview Data

enum SearchResultsPreviewData {
    static let recipe1 = Recipe(
        title: "鶏の照り焼き",
        description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。",
        imageURLs: [],
        ingredientsInfo: Ingredients(
            servings: "2人分",
            sections: [
                IngredientSection(items: [
                    Ingredient(name: "鶏もも肉", amount: "2枚"),
                    Ingredient(name: "醤油", amount: "大さじ3"),
                ]),
            ]
        ),
        stepSections: [
            CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "鶏もも肉を切る"),
            ]),
        ]
    )

    static let recipe2 = Recipe(
        title: "鶏肉カレー",
        description: "スパイシーで美味しいカレー",
        imageURLs: [],
        ingredientsInfo: Ingredients(
            servings: "4人分",
            sections: [
                IngredientSection(items: [
                    Ingredient(name: "鶏むね肉", amount: "300g"),
                    Ingredient(name: "カレールー", amount: "1箱"),
                ]),
            ]
        ),
        stepSections: [
            CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                CookingStep(stepNumber: 2, instruction: "煮込む"),
            ]),
        ]
    )

    static let cat1 = RecipeCategory(name: "和食")
    static let cat2 = RecipeCategory(name: "中華")
}

// MARK: - Preview

#Preview("SearchResults Empty") {
    NavigationStack {
        RecipeSearchResultsView(
            results: [],
            categories: [],
            selectedCategoryID: nil,
            categoryCounts: [:],
            totalCount: 0,
            onRecipeTapped: { _ in },
            onCategoryTapped: { _ in }
        )
    }
    .prefireEnabled()
}

#Preview("SearchResults With Results") {
    NavigationStack {
        RecipeSearchResultsView(
            results: [
                RecipeSearchResult(recipe: SearchResultsPreviewData.recipe1, matchFields: [.title, .ingredients]),
                RecipeSearchResult(recipe: SearchResultsPreviewData.recipe2, matchFields: [.title, .description, .ingredients, .steps]),
            ],
            categories: [SearchResultsPreviewData.cat1, SearchResultsPreviewData.cat2],
            selectedCategoryID: nil,
            categoryCounts: [SearchResultsPreviewData.cat1.id: 1, SearchResultsPreviewData.cat2.id: 0],
            totalCount: 2,
            onRecipeTapped: { _ in },
            onCategoryTapped: { _ in }
        )
        .navigationTitle(String(localized: .searchResultsTitle))
    }
    .prefireEnabled()
}
