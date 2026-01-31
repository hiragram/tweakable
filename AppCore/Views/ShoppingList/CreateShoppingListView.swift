import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum CreateShoppingListAccessibilityID {
    static let nameTextField = "createShoppingList_textField_name"
    static let recipeList = "createShoppingList_list_recipes"
    static let createButton = "createShoppingList_button_create"
    static let cancelButton = "createShoppingList_button_cancel"
    static func recipeCheckbox(_ id: UUID) -> String { "createShoppingList_button_recipe_\(id.uuidString)" }
}

// MARK: - CreateShoppingListView

/// 買い物リスト作成画面
struct CreateShoppingListView: View {
    private let ds = DesignSystem.default

    let savedRecipes: [Recipe]
    let isCreating: Bool
    let onCreateTapped: (String, [UUID]) -> Void
    let onCancelTapped: () -> Void

    @State private var listName: String = ""
    @State private var selectedRecipeIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ds.spacing.xl) {
                    // List name section
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

                    // Recipe selection section
                    VStack(alignment: .leading, spacing: ds.spacing.sm) {
                        Text(.createShoppingListRecipesHeader)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ds.colors.textSecondary.color)

                        if savedRecipes.isEmpty {
                            emptyRecipesView
                        } else {
                            VStack(spacing: ds.spacing.sm) {
                                ForEach(savedRecipes) { recipe in
                                    recipeRow(recipe)
                                }
                            }

                            Text(.createShoppingListRecipesFooter(selectedRecipeIDs.count))
                                .font(.caption)
                                .foregroundColor(ds.colors.textTertiary.color)
                        }
                    }

                    Spacer()
                        .frame(height: ds.spacing.lg)
                }
                .padding(.horizontal, ds.spacing.lg)
                .padding(.vertical, ds.spacing.md)
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

    // MARK: - Recipe Row

    private func recipeRow(_ recipe: Recipe) -> some View {
        Button(action: {
            if selectedRecipeIDs.contains(recipe.id) {
                selectedRecipeIDs.remove(recipe.id)
            } else {
                selectedRecipeIDs.insert(recipe.id)
            }
        }) {
            HStack(spacing: ds.spacing.md) {
                // Checkbox
                Image(systemName: selectedRecipeIDs.contains(recipe.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(
                        selectedRecipeIDs.contains(recipe.id)
                            ? ds.colors.primaryBrand.color
                            : ds.colors.textTertiary.color
                    )

                // Recipe info
                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(recipe.title)
                        .font(.body)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .lineLimit(2)

                    HStack(spacing: ds.spacing.sm) {
                        Label(
                            "\(recipe.ingredientsInfo.items.count)",
                            systemImage: "carrot.fill"
                        )
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)
                    }
                }

                Spacer()
            }
            .padding(ds.spacing.md)
            .background(
                selectedRecipeIDs.contains(recipe.id)
                    ? ds.colors.primaryBrand.color.opacity(0.1)
                    : ds.colors.backgroundSecondary.color
            )
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ds.cornerRadius.md)
                    .stroke(
                        selectedRecipeIDs.contains(recipe.id)
                            ? ds.colors.primaryBrand.color
                            : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(CreateShoppingListAccessibilityID.recipeCheckbox(recipe.id))
    }
}

// MARK: - Preview

#Preview("CreateShoppingList Empty") {
    CreateShoppingListView(
        savedRecipes: [],
        isCreating: false,
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
        isCreating: false,
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
                    items: [Ingredient(name: "鶏もも肉", amount: "2枚")]
                ),
                steps: []
            )
        ],
        isCreating: true,
        onCreateTapped: { _, _ in },
        onCancelTapped: {}
    )
    .prefireEnabled()
}
