import Testing
@testable import AppCore

/// AppStoreのプレミアム機能テスト
@Suite
@MainActor
struct AppStorePremiumTests {

    // MARK: - Test Helpers

    private func makeSampleRecipe() -> Recipe {
        Recipe(
            title: "テスト用チキンカレー",
            ingredientsInfo: Ingredients(
                servings: "2人分",
                items: [
                    Ingredient(name: "鶏もも肉", amount: "300g"),
                    Ingredient(name: "玉ねぎ", amount: "1個"),
                    Ingredient(name: "カレールー", amount: "4かけ")
                ]
            ),
            steps: [
                CookingStep(stepNumber: 1, instruction: "鶏肉を一口大に切る"),
                CookingStep(stepNumber: 2, instruction: "玉ねぎをみじん切りにする")
            ]
        )
    }

    // MARK: - requiresPremium Tests

    @Test("非プレミアムユーザーが置き換えをリクエストするとエラーが発生する")
    func requestSubstitution_whenNotPremium_setsError() async {
        // Arrange
        let mockRevenueCatService = MockRevenueCatServiceForTests()
        mockRevenueCatService.isPremium = false

        let mockRecipeService = MockRecipeExtractionService()
        let store = AppStore(
            recipeExtractionService: mockRecipeService,
            revenueCatService: mockRevenueCatService
        )

        // サブスクリプション状態を非プレミアムに設定
        store.send(.subscription(.subscriptionStatusLoaded(isPremium: false)))

        // レシピを設定
        let recipe = makeSampleRecipe()
        store.send(.recipe(.recipeLoaded(recipe)))

        // 置き換え対象を設定
        let targetIngredient = recipe.ingredientsInfo.items[0]
        store.send(.recipe(.openSubstitutionSheet(ingredient: targetIngredient)))

        // Act
        store.send(.recipe(.requestSubstitution(prompt: "鶏肉を豚肉に変えて")))

        // 副作用が実行されるまで待機
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Assert
        #expect(store.state.recipe.errorMessage != nil)
        #expect(store.state.recipe.errorMessage?.contains("Premium") == true ||
                store.state.recipe.errorMessage?.contains("プレミアム") == true)
    }

    @Test("プレミアムユーザーは置き換えをリクエストできる")
    func requestSubstitution_whenPremium_doesNotSetPremiumError() async {
        // Arrange
        let mockRevenueCatService = MockRevenueCatServiceForTests()
        mockRevenueCatService.isPremium = true

        let mockRecipeService = MockRecipeExtractionService()
        let store = AppStore(
            recipeExtractionService: mockRecipeService,
            revenueCatService: mockRevenueCatService
        )

        // サブスクリプション状態をプレミアムに設定
        store.send(.subscription(.subscriptionStatusLoaded(isPremium: true)))

        // レシピを設定
        let recipe = makeSampleRecipe()
        store.send(.recipe(.recipeLoaded(recipe)))

        // 置き換え対象を設定
        let targetIngredient = recipe.ingredientsInfo.items[0]
        store.send(.recipe(.openSubstitutionSheet(ingredient: targetIngredient)))

        // Act
        store.send(.recipe(.requestSubstitution(prompt: "鶏肉を豚肉に変えて")))

        // 副作用が実行されるまで待機
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Assert - プレミアムエラーは発生しない
        // (他のエラーは発生しうる：モックなのでsubstitutionRecipeが設定されていないなど)
        let error = store.state.recipe.errorMessage
        if let error = error {
            #expect(!error.contains("Premium") && !error.contains("プレミアム"))
        }
    }

    @Test("非プレミアムユーザーが追加置き換えをリクエストするとエラーが発生する")
    func requestAdditionalSubstitution_whenNotPremium_setsError() async {
        // Arrange
        let mockRevenueCatService = MockRevenueCatServiceForTests()
        mockRevenueCatService.isPremium = false

        let mockRecipeService = MockRecipeExtractionService()
        let store = AppStore(
            recipeExtractionService: mockRecipeService,
            revenueCatService: mockRevenueCatService
        )

        // サブスクリプション状態を非プレミアムに設定
        store.send(.subscription(.subscriptionStatusLoaded(isPremium: false)))

        // レシピを設定
        let recipe = makeSampleRecipe()
        store.send(.recipe(.recipeLoaded(recipe)))

        // プレビューを設定（追加置き換えはプレビュー状態から始まる）
        store.send(.recipe(.substitutionPreviewReady(recipe)))

        // 置き換え対象を設定
        let targetIngredient = recipe.ingredientsInfo.items[0]
        store.send(.recipe(.openSubstitutionSheet(ingredient: targetIngredient)))

        // Act
        store.send(.recipe(.requestAdditionalSubstitution(prompt: "さらに野菜を変えて")))

        // 副作用が実行されるまで待機
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Assert
        #expect(store.state.recipe.errorMessage != nil)
        #expect(store.state.recipe.errorMessage?.contains("Premium") == true ||
                store.state.recipe.errorMessage?.contains("プレミアム") == true)
    }

    // MARK: - Auto-Save on Substitution Approval Tests

    @Test("保存済みレシピをカスタマイズして承認すると自動保存される")
    func approveSubstitution_whenRecipeIsSaved_triggersAutoSave() async {
        // Arrange
        let mockPersistenceService = MockRecipePersistenceService()
        let store = AppStore(
            recipeExtractionService: MockRecipeExtractionService(),
            recipePersistenceService: mockPersistenceService,
            revenueCatService: MockRevenueCatServiceForTests()
        )

        // 保存済みレシピを作成（savedRecipesにも存在する状態）
        let recipe = makeSampleRecipe()
        store.send(.recipe(.savedRecipesLoaded([recipe])))
        store.send(.recipe(.selectSavedRecipe(recipe)))

        // 置き換えプレビューを準備（カスタマイズ結果）
        var modifiedRecipe = recipe
        modifiedRecipe.ingredientsInfo.items[0] = Ingredient(name: "豚もも肉", amount: "300g", isModified: true)
        store.send(.recipe(.substitutionPreviewReady(modifiedRecipe)))

        // Act - 置き換えを承認
        store.send(.recipe(.approveSubstitution))

        // 副作用が実行されるまで待機
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Assert - 自動保存が呼ばれる
        #expect(mockPersistenceService.saveRecipeCallCount == 1)
    }

    @Test("未保存の新規レシピをカスタマイズして承認しても自動保存されない")
    func approveSubstitution_whenRecipeIsNotSaved_doesNotTriggerAutoSave() async {
        // Arrange
        let mockPersistenceService = MockRecipePersistenceService()
        let store = AppStore(
            recipeExtractionService: MockRecipeExtractionService(),
            recipePersistenceService: mockPersistenceService,
            revenueCatService: MockRevenueCatServiceForTests()
        )

        // 新規レシピを読み込み（savedRecipesには含まれない）
        let recipe = makeSampleRecipe()
        store.send(.recipe(.recipeLoaded(recipe)))

        // 置き換えプレビューを準備
        var modifiedRecipe = recipe
        modifiedRecipe.ingredientsInfo.items[0] = Ingredient(name: "豚もも肉", amount: "300g", isModified: true)
        store.send(.recipe(.substitutionPreviewReady(modifiedRecipe)))

        // Act - 置き換えを承認
        store.send(.recipe(.approveSubstitution))

        // 副作用が実行されるまで待機
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Assert - 自動保存は呼ばれない
        #expect(mockPersistenceService.saveRecipeCallCount == 0)
    }
}
