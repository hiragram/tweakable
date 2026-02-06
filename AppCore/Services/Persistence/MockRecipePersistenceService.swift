//
//  MockRecipePersistenceService.swift
//  AppCore
//
//  UIテスト用のモック永続化サービス
//

import Foundation

/// UIテスト用の保存済みレシピをモックするサービス
public final class MockRecipePersistenceService: RecipePersistenceServiceProtocol, Sendable {
    private let mockRecipes: [Recipe]

    public init(mockRecipes: [Recipe]? = nil) {
        self.mockRecipes = mockRecipes ?? MockRecipePersistenceService.defaultMockRecipes
    }

    /// デフォルトのモックレシピ（一度だけ生成）
    public static let defaultMockRecipes: [Recipe] =
        [
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
                            Ingredient(name: "砂糖", amount: "大さじ1")
                        ])
                    ]
                ),
                stepSections: [
                    CookingStepSection(items: [
                        CookingStep(stepNumber: 1, instruction: "鶏もも肉を一口大に切る"),
                        CookingStep(stepNumber: 2, instruction: "フライパンで皮目から焼く"),
                        CookingStep(stepNumber: 3, instruction: "調味料を加えて煮絡める"),
                        CookingStep(stepNumber: 4, instruction: "照りが出たら完成")
                    ])
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
                            Ingredient(name: "カレールー", amount: "1箱")
                        ])
                    ]
                ),
                stepSections: [
                    CookingStepSection(items: [
                        CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                        CookingStep(stepNumber: 2, instruction: "肉を炒める"),
                        CookingStep(stepNumber: 3, instruction: "野菜を加えて煮込む"),
                        CookingStep(stepNumber: 4, instruction: "ルーを溶かす")
                    ])
                ]
            )
        ]

    // MARK: - Recipe Operations

    public func saveRecipe(_ recipe: Recipe) async throws {
        // No-op for mock
    }

    public func loadRecipe(id: UUID) async throws -> Recipe? {
        mockRecipes.first { $0.id == id }
    }

    public func loadAllRecipes() async throws -> [Recipe] {
        mockRecipes
    }

    public func deleteRecipe(id: UUID) async throws {
        // No-op for mock
    }

    // MARK: - ShoppingList Operations

    public func createShoppingList(name: String, recipeIDs: [UUID]) async throws -> ShoppingListDTO {
        ShoppingListDTO(
            id: UUID(),
            name: name,
            createdAt: Date(),
            updatedAt: Date(),
            recipeIDs: recipeIDs,
            items: []
        )
    }

    public func loadShoppingList(id: UUID) async throws -> ShoppingListDTO? {
        nil
    }

    public func loadAllShoppingLists() async throws -> [ShoppingListDTO] {
        []
    }

    public func addRecipeToShoppingList(listID: UUID, recipeID: UUID) async throws {
        // No-op
    }

    public func removeRecipeFromShoppingList(listID: UUID, recipeID: UUID) async throws {
        // No-op
    }

    public func deleteShoppingList(id: UUID) async throws {
        // No-op
    }

    public func updateShoppingItemChecked(itemID: UUID, isChecked: Bool) async throws {
        // No-op
    }

    // MARK: - Category Operations

    public func loadAllCategories() async throws -> (categories: [RecipeCategory], categoryRecipeMap: [UUID: Set<UUID>]) {
        (categories: [], categoryRecipeMap: [:])
    }

    public func createCategory(name: String) async throws -> RecipeCategory {
        RecipeCategory(name: name)
    }

    public func renameCategory(id: UUID, newName: String) async throws -> RecipeCategory {
        RecipeCategory(id: id, name: newName)
    }

    public func deleteCategory(id: UUID) async throws {
        // No-op for mock
    }

    public func addRecipeToCategory(recipeID: UUID, categoryID: UUID) async throws {
        // No-op for mock
    }

    public func removeRecipeFromCategory(recipeID: UUID, categoryID: UUID) async throws {
        // No-op for mock
    }

    // MARK: - Debug Operations

    public func deleteAllData() async throws {
        // No-op for mock
    }
}
