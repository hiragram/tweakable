import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum CreateShoppingListAccessibilityID {
    static let nameTextField = "createShoppingList_textField_name"
    static let recipeList = "createShoppingList_list_recipes"
    static let createButton = "createShoppingList_button_create"
    static let cancelButton = "createShoppingList_button_cancel"
    static func recipeRow(_ id: UUID) -> String { "createShoppingList_button_recipe_\(id.uuidString)" }
    static let categoryAll = "createShoppingList_button_categoryAll"
    static func categoryChip(_ id: UUID) -> String { "createShoppingList_button_category_\(id.uuidString)" }
}

// MARK: - CreateShoppingListView

/// 買い物リスト作成画面
struct CreateShoppingListView: View {
    private let ds = DesignSystem.default

    let savedRecipes: [Recipe]
    let searchResults: [RecipeSearchResult]
    let categories: [RecipeCategory]
    let selectedCategoryID: UUID?
    let categoryCounts: [UUID: Int]
    let totalSearchResultCount: Int
    let isSearchActive: Bool
    let isCreating: Bool
    let onCategoryTapped: (UUID?) -> Void
    let onCreateTapped: (String, [UUID]) -> Void
    let onCancelTapped: () -> Void

    @State private var listName: String = ""
    @State private var selectedRecipeIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ds.spacing.xl) {
                    // List name section
                    nameSection

                    // Recipe selection section
                    recipeSection

                    Spacer()
                        .frame(height: ds.spacing.lg)
                }
                .padding(.horizontal, ds.spacing.lg)
                .padding(.vertical, ds.spacing.md)
            }
            .safeAreaInset(edge: .bottom) {
                SelectedRecipesThumbnailBar(
                    selectedRecipes: selectedRecipesOrdered,
                    onRemoveTapped: { id in
                        selectedRecipeIDs.remove(id)
                    }
                )
                .background(ds.colors.backgroundPrimary.color)
            }
            .accessibilityIdentifier(CreateShoppingListAccessibilityID.recipeList)
            .navigationTitle(String(localized: .createShoppingListTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: .commonCancel)) {
                        onCancelTapped()
                    }
                    .accessibilityIdentifier(CreateShoppingListAccessibilityID.cancelButton)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        onCreateTapped(listName, Array(selectedRecipeIDs))
                    }) {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text(.commonCreate)
                        }
                    }
                    .disabled(listName.isEmpty || selectedRecipeIDs.isEmpty || isCreating)
                    .accessibilityIdentifier(CreateShoppingListAccessibilityID.createButton)
                }
            }
        }
    }

    // MARK: - Selected Recipes (Ordered)

    private var selectedRecipesOrdered: [Recipe] {
        savedRecipes.filter { selectedRecipeIDs.contains($0.id) }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            Text(.createShoppingListNameHeader)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ds.colors.textSecondary.color)

            TextField(
                String(localized: .createShoppingListNamePlaceholder),
                text: $listName
            )
            .textFieldStyle(.plain)
            .padding(ds.spacing.md)
            .background(ds.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            .accessibilityIdentifier(CreateShoppingListAccessibilityID.nameTextField)
        }
    }

    // MARK: - Recipe Section

    private var recipeSection: some View {
        VStack(alignment: .leading, spacing: ds.spacing.sm) {
            Text(.createShoppingListRecipesHeader)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ds.colors.textSecondary.color)

            if savedRecipes.isEmpty {
                emptyRecipesView
            } else if isSearchActive {
                searchResultsContent
            } else {
                savedRecipesContent
            }

            if !savedRecipes.isEmpty {
                Text(.createShoppingListRecipesFooter(selectedRecipeIDs.count))
                    .font(.caption)
                    .foregroundColor(ds.colors.textTertiary.color)
            }
        }
    }

    // MARK: - Saved Recipes Content (Non-Search)

    private var savedRecipesContent: some View {
        LazyVStack(spacing: 0) {
            ForEach(savedRecipes) { recipe in
                recipeListRow(recipe: recipe, matchFields: nil)
                if recipe.id != savedRecipes.last?.id {
                    Divider()
                        .padding(.leading, 60 + ds.spacing.md * 2)
                }
            }
        }
    }

    // MARK: - Search Results Content

    private var searchResultsContent: some View {
        VStack(spacing: ds.spacing.sm) {
            if !categories.isEmpty {
                categoryChipsView
            }

            if searchResults.isEmpty {
                emptyRecipesView
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { result in
                        recipeListRow(recipe: result.recipe, matchFields: result.matchFields)
                        if result.id != searchResults.last?.id {
                            Divider()
                                .padding(.leading, 60 + ds.spacing.md * 2)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recipe List Row

    private func recipeListRow(recipe: Recipe, matchFields: SearchMatchField?) -> some View {
        RecipeListRow(
            recipe: recipe,
            matchFields: matchFields,
            accessibilityID: CreateShoppingListAccessibilityID.recipeRow(recipe.id),
            trailingAccessory: {
                Image(systemName: selectedRecipeIDs.contains(recipe.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(
                        selectedRecipeIDs.contains(recipe.id)
                            ? ds.colors.primaryBrand.color
                            : ds.colors.textTertiary.color
                    )
            },
            onTapped: {
                if selectedRecipeIDs.contains(recipe.id) {
                    selectedRecipeIDs.remove(recipe.id)
                } else {
                    selectedRecipeIDs.insert(recipe.id)
                }
            }
        )
    }

    // MARK: - Category Chips

    private var categoryChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ds.spacing.xs) {
                categoryChipWithCount(
                    label: String(localized: .searchResultsCategoryAll),
                    count: totalSearchResultCount,
                    isSelected: selectedCategoryID == nil,
                    accessibilityID: CreateShoppingListAccessibilityID.categoryAll
                ) {
                    onCategoryTapped(nil)
                }

                ForEach(categories) { category in
                    categoryChipWithCount(
                        label: category.name,
                        count: categoryCounts[category.id] ?? 0,
                        isSelected: selectedCategoryID == category.id,
                        accessibilityID: CreateShoppingListAccessibilityID.categoryChip(category.id)
                    ) {
                        onCategoryTapped(category.id)
                    }
                }
            }
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

    // MARK: - Empty Recipes View

    private var emptyRecipesView: some View {
        VStack(spacing: ds.spacing.md) {
            Image(systemName: "bookmark.slash")
                .font(.title)
                .foregroundColor(ds.colors.textTertiary.color)

            Text(.createShoppingListNoRecipes)
                .font(.subheadline)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(ds.spacing.xl)
        .background(ds.colors.backgroundSecondary.color)
        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
    }
}

// MARK: - Preview

#Preview("CreateShoppingList Empty") {
    CreateShoppingListView(
        savedRecipes: [],
        searchResults: [],
        categories: [],
        selectedCategoryID: nil,
        categoryCounts: [:],
        totalSearchResultCount: 0,
        isSearchActive: false,
        isCreating: false,
        onCategoryTapped: { _ in },
        onCreateTapped: { _, _ in },
        onCancelTapped: {}
    )
    .prefireEnabled()
}

#Preview("CreateShoppingList With Recipes") {
    CreateShoppingListView(
        savedRecipes: [
            Recipe(
                title: "鶏の照り焼き",
                description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。",
                imageURLs: [],
                ingredientsInfo: Ingredients(
                    servings: "2人分",
                    sections: [
                        IngredientSection(items: [
                            Ingredient(name: "鶏もも肉", amount: "2枚"),
                            Ingredient(name: "醤油", amount: "大さじ3"),
                            Ingredient(name: "みりん", amount: "大さじ2"),
                        ]),
                    ]
                ),
                stepSections: [
                    CookingStepSection(items: [
                        CookingStep(stepNumber: 1, instruction: "鶏もも肉を切る"),
                        CookingStep(stepNumber: 2, instruction: "焼く"),
                    ]),
                ]
            ),
            Recipe(
                title: "カレーライス",
                description: "家庭の定番カレー",
                imageURLs: [],
                ingredientsInfo: Ingredients(
                    servings: "4人分",
                    sections: [
                        IngredientSection(items: [
                            Ingredient(name: "豚肉", amount: "300g"),
                            Ingredient(name: "玉ねぎ", amount: "2個"),
                            Ingredient(name: "人参", amount: "1本"),
                            Ingredient(name: "じゃがいも", amount: "2個"),
                            Ingredient(name: "カレールー", amount: "1箱"),
                        ]),
                    ]
                ),
                stepSections: [
                    CookingStepSection(items: [
                        CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                        CookingStep(stepNumber: 2, instruction: "肉を炒める"),
                        CookingStep(stepNumber: 3, instruction: "野菜を加えて煮込む"),
                        CookingStep(stepNumber: 4, instruction: "ルーを溶かす"),
                    ]),
                ]
            ),
        ],
        searchResults: [],
        categories: [],
        selectedCategoryID: nil,
        categoryCounts: [:],
        totalSearchResultCount: 0,
        isSearchActive: false,
        isCreating: false,
        onCategoryTapped: { _ in },
        onCreateTapped: { _, _ in },
        onCancelTapped: {}
    )
    .prefireEnabled()
}

#Preview("CreateShoppingList Creating") {
    CreateShoppingListView(
        savedRecipes: [
            Recipe(
                title: "鶏の照り焼き",
                description: nil,
                imageURLs: [],
                ingredientsInfo: Ingredients(
                    servings: "2人分",
                    sections: [
                        IngredientSection(items: [Ingredient(name: "鶏もも肉", amount: "2枚")]),
                    ]
                ),
                stepSections: []
            ),
        ],
        searchResults: [],
        categories: [],
        selectedCategoryID: nil,
        categoryCounts: [:],
        totalSearchResultCount: 0,
        isSearchActive: false,
        isCreating: true,
        onCategoryTapped: { _ in },
        onCreateTapped: { _, _ in },
        onCancelTapped: {}
    )
    .prefireEnabled()
}
