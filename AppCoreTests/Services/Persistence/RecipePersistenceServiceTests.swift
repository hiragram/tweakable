import Testing
import SwiftData
@testable import AppCore

@Suite
struct RecipePersistenceServiceTests {

    // MARK: - Helper

    private func makeService() throws -> RecipePersistenceService {
        let schema = Schema([
            PersistedRecipe.self,
            PersistedIngredientSection.self,
            PersistedIngredient.self,
            PersistedCookingStepSection.self,
            PersistedCookingStep.self,
            PersistedShoppingList.self,
            PersistedShoppingListItem.self,
            PersistedShoppingListItemBreakdown.self,
            PersistedRecipeCategory.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return RecipePersistenceService(modelContainer: container)
    }

    private func makeSampleRecipe(
        id: UUID = UUID(),
        title: String = "テストレシピ"
    ) -> Recipe {
        Recipe(
            id: id,
            title: title,
            description: "おいしい料理",
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(items: [
                        Ingredient(name: "鶏肉", amount: "200g"),
                        Ingredient(name: "塩", amount: "少々")
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "材料を切る"),
                    CookingStep(stepNumber: 2, instruction: "炒める")
                ])
            ],
            sourceURL: URL(string: "https://example.com/recipe")
        )
    }

    // MARK: - Recipe Save/Load Tests

    @Test
    func saveRecipe_persistsRecipe() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()

        try await service.saveRecipe(recipe)

        let loaded = try await service.loadRecipe(id: recipe.id)
        #expect(loaded != nil)
        #expect(loaded?.title == "テストレシピ")
    }

    @Test
    func loadRecipe_nonExistent_returnsNil() async throws {
        let service = try makeService()

        let loaded = try await service.loadRecipe(id: UUID())
        #expect(loaded == nil)
    }

    @Test
    func loadAllRecipes_returnsAllSavedRecipes() async throws {
        let service = try makeService()
        let recipe1 = makeSampleRecipe(title: "レシピ1")
        let recipe2 = makeSampleRecipe(title: "レシピ2")

        try await service.saveRecipe(recipe1)
        try await service.saveRecipe(recipe2)

        let all = try await service.loadAllRecipes()
        #expect(all.count == 2)
    }

    @Test
    func deleteRecipe_removesRecipe() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()

        try await service.saveRecipe(recipe)
        try await service.deleteRecipe(id: recipe.id)

        let loaded = try await service.loadRecipe(id: recipe.id)
        #expect(loaded == nil)
    }

    @Test
    func saveRecipe_withSameID_updatesExisting() async throws {
        let service = try makeService()
        let id = UUID()
        let recipe1 = makeSampleRecipe(id: id, title: "初期タイトル")
        let recipe2 = makeSampleRecipe(id: id, title: "更新タイトル")

        try await service.saveRecipe(recipe1)
        try await service.saveRecipe(recipe2)

        let all = try await service.loadAllRecipes()
        #expect(all.count == 1)
        #expect(all.first?.title == "更新タイトル")
    }

    // MARK: - ShoppingList Tests

    @Test
    func createShoppingList_createsListWithRecipes() async throws {
        let service = try makeService()
        let recipe1 = makeSampleRecipe(title: "レシピA")
        let recipe2 = makeSampleRecipe(title: "レシピB")

        try await service.saveRecipe(recipe1)
        try await service.saveRecipe(recipe2)

        let list = try await service.createShoppingList(
            name: "今週の買い物",
            recipeIDs: [recipe1.id, recipe2.id]
        )

        #expect(list.name == "今週の買い物")
        #expect(list.recipeIDs.count == 2)
    }

    @Test
    func createShoppingList_aggregatesIngredients() async throws {
        let service = try makeService()

        // 同じ材料「鶏肉」を持つ2つのレシピ
        let recipe1 = Recipe(
            id: UUID(),
            title: "レシピA",
            ingredientsInfo: Ingredients(sections: [
                IngredientSection(items: [
                    Ingredient(name: "鶏肉", amount: "200g"),
                    Ingredient(name: "玉ねぎ", amount: "1個")
                ])
            ]),
            stepSections: []
        )
        let recipe2 = Recipe(
            id: UUID(),
            title: "レシピB",
            ingredientsInfo: Ingredients(sections: [
                IngredientSection(items: [
                    Ingredient(name: "鶏肉", amount: "300g"),
                    Ingredient(name: "にんにく", amount: "2片")
                ])
            ]),
            stepSections: []
        )

        try await service.saveRecipe(recipe1)
        try await service.saveRecipe(recipe2)

        let list = try await service.createShoppingList(
            name: "テスト",
            recipeIDs: [recipe1.id, recipe2.id]
        )

        // 鶏肉は集約されて1つのアイテムに
        let chickenItem = list.items.first { $0.name == "鶏肉" }
        #expect(chickenItem != nil)
        #expect(chickenItem?.breakdowns.count == 2)

        // 他の材料は個別
        #expect(list.items.contains { $0.name == "玉ねぎ" })
        #expect(list.items.contains { $0.name == "にんにく" })
    }

    @Test
    func loadShoppingList_returnsListWithItems() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()

        try await service.saveRecipe(recipe)
        let created = try await service.createShoppingList(
            name: "テストリスト",
            recipeIDs: [recipe.id]
        )

        let loaded = try await service.loadShoppingList(id: created.id)
        #expect(loaded != nil)
        #expect(loaded?.name == "テストリスト")
        #expect(loaded?.items.count == 2) // 鶏肉と塩
    }

    @Test
    func loadAllShoppingLists_returnsAllLists() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()

        try await service.saveRecipe(recipe)
        _ = try await service.createShoppingList(name: "リスト1", recipeIDs: [recipe.id])
        _ = try await service.createShoppingList(name: "リスト2", recipeIDs: [recipe.id])

        let all = try await service.loadAllShoppingLists()
        #expect(all.count == 2)
    }

    @Test
    func deleteShoppingList_removesList() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()

        try await service.saveRecipe(recipe)
        let list = try await service.createShoppingList(name: "削除テスト", recipeIDs: [recipe.id])
        try await service.deleteShoppingList(id: list.id)

        let loaded = try await service.loadShoppingList(id: list.id)
        #expect(loaded == nil)
    }

    @Test
    func updateShoppingItemChecked_updatesCheckState() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()

        try await service.saveRecipe(recipe)
        let list = try await service.createShoppingList(name: "チェックテスト", recipeIDs: [recipe.id])

        guard let itemID = list.items.first?.id else {
            Issue.record("アイテムが存在しません")
            return
        }

        try await service.updateShoppingItemChecked(itemID: itemID, isChecked: true)

        let reloaded = try await service.loadShoppingList(id: list.id)
        let item = reloaded?.items.first { $0.id == itemID }
        #expect(item?.isChecked == true)
    }

    // MARK: - Debug Operations Tests

    @Test
    func deleteAllData_removesAllRecipesAndShoppingLists() async throws {
        let service = try makeService()

        // レシピを保存
        let recipe1 = makeSampleRecipe(title: "レシピ1")
        let recipe2 = makeSampleRecipe(title: "レシピ2")
        try await service.saveRecipe(recipe1)
        try await service.saveRecipe(recipe2)

        // 買い物リストを作成
        _ = try await service.createShoppingList(name: "リスト1", recipeIDs: [recipe1.id])
        _ = try await service.createShoppingList(name: "リスト2", recipeIDs: [recipe2.id])

        // 全削除
        try await service.deleteAllData()

        // レシピが空になっていること
        let recipes = try await service.loadAllRecipes()
        #expect(recipes.isEmpty)

        // 買い物リストも空になっていること
        let lists = try await service.loadAllShoppingLists()
        #expect(lists.isEmpty)
    }

    // MARK: - Category Tests

    @Test
    func createCategory_createsAndReturnsCategoryWithName() async throws {
        let service = try makeService()

        let category = try await service.createCategory(name: "メインディッシュ")

        #expect(category.name == "メインディッシュ")
        #expect(category.id != UUID()) // IDが生成されていること
    }

    @Test
    func createCategory_emptyName_throwsInvalidCategoryName() async throws {
        let service = try makeService()

        await #expect(throws: PersistenceError.invalidCategoryName) {
            try await service.createCategory(name: "")
        }
    }

    @Test
    func renameCategory_updatesName() async throws {
        let service = try makeService()
        let category = try await service.createCategory(name: "旧名前")

        let renamed = try await service.renameCategory(id: category.id, newName: "新名前")

        #expect(renamed.name == "新名前")
        #expect(renamed.id == category.id)
    }

    @Test
    func renameCategory_nonExistent_throwsCategoryNotFound() async throws {
        let service = try makeService()

        await #expect(throws: PersistenceError.categoryNotFound) {
            try await service.renameCategory(id: UUID(), newName: "何か")
        }
    }

    @Test
    func deleteCategory_removesCategory() async throws {
        let service = try makeService()
        let category = try await service.createCategory(name: "削除対象")

        try await service.deleteCategory(id: category.id)

        let result = try await service.loadAllCategories()
        #expect(result.categories.isEmpty)
    }

    @Test
    func deleteCategory_doesNotDeleteRecipes() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()
        try await service.saveRecipe(recipe)

        let category = try await service.createCategory(name: "カテゴリ")
        try await service.addRecipeToCategory(recipeID: recipe.id, categoryID: category.id)

        // カテゴリを削除
        try await service.deleteCategory(id: category.id)

        // レシピはまだ存在すること
        let loaded = try await service.loadRecipe(id: recipe.id)
        #expect(loaded != nil)
        #expect(loaded?.title == recipe.title)
    }

    @Test
    func addRecipeToCategory_createsAssociation() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()
        try await service.saveRecipe(recipe)
        let category = try await service.createCategory(name: "お気に入り")

        try await service.addRecipeToCategory(recipeID: recipe.id, categoryID: category.id)

        let result = try await service.loadAllCategories()
        let recipeIDs = result.categoryRecipeMap[category.id]
        #expect(recipeIDs != nil)
        #expect(recipeIDs?.contains(recipe.id) == true)
    }

    @Test
    func addRecipeToCategory_duplicateIsIgnored() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()
        try await service.saveRecipe(recipe)
        let category = try await service.createCategory(name: "お気に入り")

        // 同じレシピを2回追加
        try await service.addRecipeToCategory(recipeID: recipe.id, categoryID: category.id)
        try await service.addRecipeToCategory(recipeID: recipe.id, categoryID: category.id)

        let result = try await service.loadAllCategories()
        let recipeIDs = result.categoryRecipeMap[category.id]
        #expect(recipeIDs?.count == 1)
    }

    @Test
    func removeRecipeFromCategory_removesAssociation() async throws {
        let service = try makeService()
        let recipe = makeSampleRecipe()
        try await service.saveRecipe(recipe)
        let category = try await service.createCategory(name: "お気に入り")

        try await service.addRecipeToCategory(recipeID: recipe.id, categoryID: category.id)
        try await service.removeRecipeFromCategory(recipeID: recipe.id, categoryID: category.id)

        let result = try await service.loadAllCategories()
        let recipeIDs = result.categoryRecipeMap[category.id]
        #expect(recipeIDs?.isEmpty == true)
    }

    @Test
    func loadAllCategories_returnsCategoriesWithRecipeMap() async throws {
        let service = try makeService()
        let recipe1 = makeSampleRecipe(title: "レシピ1")
        let recipe2 = makeSampleRecipe(title: "レシピ2")
        try await service.saveRecipe(recipe1)
        try await service.saveRecipe(recipe2)

        let cat1 = try await service.createCategory(name: "カテゴリA")
        let cat2 = try await service.createCategory(name: "カテゴリB")

        try await service.addRecipeToCategory(recipeID: recipe1.id, categoryID: cat1.id)
        try await service.addRecipeToCategory(recipeID: recipe2.id, categoryID: cat1.id)
        try await service.addRecipeToCategory(recipeID: recipe2.id, categoryID: cat2.id)

        let result = try await service.loadAllCategories()

        #expect(result.categories.count == 2)
        #expect(result.categoryRecipeMap[cat1.id]?.count == 2)
        #expect(result.categoryRecipeMap[cat2.id]?.count == 1)
        #expect(result.categoryRecipeMap[cat1.id]?.contains(recipe1.id) == true)
        #expect(result.categoryRecipeMap[cat1.id]?.contains(recipe2.id) == true)
        #expect(result.categoryRecipeMap[cat2.id]?.contains(recipe2.id) == true)
    }
}
