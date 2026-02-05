import Testing
import Foundation
@testable import AppCore

@Suite
struct RecipeReducerTests {

    // MARK: - Test Helpers

    private func makeSampleRecipe() -> Recipe {
        Recipe(
            title: "テスト料理",
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
                    CookingStep(stepNumber: 1, instruction: "鶏肉を切る"),
                    CookingStep(stepNumber: 2, instruction: "塩をふる")
                ])
            ],
            sourceURL: URL(string: "https://example.com/recipe")
        )
    }

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = RecipeState()

        #expect(state.currentRecipe == nil)
        #expect(state.isLoadingRecipe == false)
        #expect(state.isProcessingSubstitution == false)
        #expect(state.errorMessage == nil)
        #expect(state.substitutionTarget == nil)
    }

    // MARK: - Load Recipe Tests

    @Test
    func reduce_loadRecipe_setsLoadingState() {
        var state = RecipeState()
        let url = URL(string: "https://example.com/recipe")!

        RecipeReducer.reduce(state: &state, action: .loadRecipe(url: url))

        #expect(state.isLoadingRecipe == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_recipeLoaded_setsRecipeAndClearsLoading() {
        var state = RecipeState()
        state.isLoadingRecipe = true
        let recipe = makeSampleRecipe()

        RecipeReducer.reduce(state: &state, action: .recipeLoaded(recipe))

        #expect(state.currentRecipe == recipe)
        #expect(state.isLoadingRecipe == false)
    }

    @Test
    func reduce_recipeLoadFailed_setsErrorAndClearsLoading() {
        var state = RecipeState()
        state.isLoadingRecipe = true

        RecipeReducer.reduce(state: &state, action: .recipeLoadFailed("ネットワークエラー"))

        #expect(state.errorMessage == "ネットワークエラー")
        #expect(state.isLoadingRecipe == false)
    }

    // MARK: - Substitution Sheet Tests

    @Test
    func reduce_openSubstitutionSheet_setsIngredientTarget() {
        var state = RecipeState()
        let ingredient = Ingredient(name: "鶏肉", amount: "200g")

        RecipeReducer.reduce(state: &state, action: .openSubstitutionSheet(ingredient: ingredient))

        #expect(state.substitutionTarget == .ingredient(ingredient))
    }

    @Test
    func reduce_openSubstitutionSheetForStep_setsStepTarget() {
        var state = RecipeState()
        let step = CookingStep(stepNumber: 1, instruction: "鶏肉を切る")

        RecipeReducer.reduce(state: &state, action: .openSubstitutionSheetForStep(step: step))

        #expect(state.substitutionTarget == .step(step))
    }

    @Test
    func reduce_closeSubstitutionSheet_clearsTarget() {
        var state = RecipeState()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))

        RecipeReducer.reduce(state: &state, action: .closeSubstitutionSheet)

        #expect(state.substitutionTarget == nil)
    }

    // MARK: - Substitution Processing Tests

    @Test
    func reduce_requestSubstitution_setsProcessingState() {
        var state = RecipeState()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))

        RecipeReducer.reduce(state: &state, action: .requestSubstitution(prompt: "豚肉に変えて"))

        #expect(state.isProcessingSubstitution == true)
    }

    @Test
    func reduce_requestSubstitution_clearsExistingError() {
        var state = RecipeState()
        state.errorMessage = "前回のエラー"
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))

        RecipeReducer.reduce(state: &state, action: .requestSubstitution(prompt: "豚肉に変えて"))

        #expect(state.errorMessage == nil)
        #expect(state.isProcessingSubstitution == true)
    }

    @Test
    func reduce_substitutionPreviewReady_setsPreviewAndChangesToPreviewMode() {
        var state = RecipeState()
        state.currentRecipe = makeSampleRecipe()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.isProcessingSubstitution = true
        state.substitutionSheetMode = .input

        let previewRecipe = Recipe(
            title: "テスト料理",
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(items: [
                        Ingredient(name: "豚肉", amount: "200g", isModified: true),
                        Ingredient(name: "塩", amount: "少々")
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "豚肉を切る", isModified: true),
                    CookingStep(stepNumber: 2, instruction: "塩をふる")
                ])
            ]
        )

        RecipeReducer.reduce(state: &state, action: .substitutionPreviewReady(previewRecipe))

        #expect(state.previewRecipe == previewRecipe)
        #expect(state.isProcessingSubstitution == false)
        #expect(state.substitutionSheetMode == .preview)
        // currentRecipeはまだ変更されない
        #expect(state.currentRecipe != previewRecipe)
    }

    @Test
    func reduce_substitutionFailed_setsErrorAndClearsProcessing() {
        var state = RecipeState()
        state.isProcessingSubstitution = true

        RecipeReducer.reduce(state: &state, action: .substitutionFailed("置き換えに失敗しました"))

        #expect(state.errorMessage == "置き換えに失敗しました")
        #expect(state.isProcessingSubstitution == false)
    }

    @Test
    func reduce_substitutionFailed_keepsSheetOpen() {
        // エラー時はシートを閉じず、リトライ可能にする
        var state = RecipeState()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.isProcessingSubstitution = true

        RecipeReducer.reduce(state: &state, action: .substitutionFailed("エラー"))

        // シートは開いたままにする（substitutionTargetはnilにならない）
        #expect(state.substitutionTarget != nil)
    }

    // MARK: - Substitution Confirmation Tests

    @Test
    func reduce_openSubstitutionSheet_savesSnapshotAndSetsInputMode() {
        var state = RecipeState()
        let recipe = makeSampleRecipe()
        state.currentRecipe = recipe
        let ingredient = Ingredient(name: "鶏肉", amount: "200g")

        RecipeReducer.reduce(state: &state, action: .openSubstitutionSheet(ingredient: ingredient))

        #expect(state.substitutionTarget == .ingredient(ingredient))
        #expect(state.originalRecipeSnapshot == recipe)
        #expect(state.substitutionSheetMode == .input)
    }

    @Test
    func reduce_openSubstitutionSheetForStep_savesSnapshotAndSetsInputMode() {
        var state = RecipeState()
        let recipe = makeSampleRecipe()
        state.currentRecipe = recipe
        let step = CookingStep(stepNumber: 1, instruction: "鶏肉を切る")

        RecipeReducer.reduce(state: &state, action: .openSubstitutionSheetForStep(step: step))

        #expect(state.substitutionTarget == .step(step))
        #expect(state.originalRecipeSnapshot == recipe)
        #expect(state.substitutionSheetMode == .input)
    }

    @Test
    func reduce_approveSubstitution_updatesRecipeAndResetsState() {
        var state = RecipeState()
        let originalRecipe = makeSampleRecipe()
        state.currentRecipe = originalRecipe
        state.originalRecipeSnapshot = originalRecipe
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview

        let previewRecipe = Recipe(
            title: "テスト料理（更新後）",
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(items: [
                        Ingredient(name: "豚肉", amount: "200g", isModified: true)
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "豚肉を切る", isModified: true)
                ])
            ]
        )
        state.previewRecipe = previewRecipe

        RecipeReducer.reduce(state: &state, action: .approveSubstitution)

        // 置き換え内容が反映されていること
        #expect(state.currentRecipe?.title == previewRecipe.title)
        #expect(state.currentRecipe?.ingredientsInfo == previewRecipe.ingredientsInfo)
        #expect(state.currentRecipe?.stepSections == previewRecipe.stepSections)
        // 元レシピのIDが保持されていること
        #expect(state.currentRecipe?.id == originalRecipe.id)
        #expect(state.substitutionTarget == nil)
        #expect(state.previewRecipe == nil)
        #expect(state.originalRecipeSnapshot == nil)
        #expect(state.substitutionSheetMode == .input)
    }

    @Test
    func reduce_approveSubstitution_preservesImageURLsFromCurrentRecipe() {
        var state = RecipeState()
        let imageURLs: [ImageSource] = [
            // swiftlint:disable:next force_unwrapping
            .remote(url: URL(string: "https://example.com/image.jpg")!)
        ]
        let originalRecipe = Recipe(
            title: "テスト料理",
            imageURLs: imageURLs,
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [IngredientSection(items: [Ingredient(name: "鶏肉", amount: "200g")])]
            ),
            stepSections: [CookingStepSection(items: [CookingStep(stepNumber: 1, instruction: "鶏肉を切る")])],
            sourceURL: URL(string: "https://example.com/recipe")
        )
        state.currentRecipe = originalRecipe
        state.originalRecipeSnapshot = originalRecipe
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview

        // LLMからの結果（imageURLsなし、新しいID）
        let previewRecipe = Recipe(
            title: "テスト料理",
            imageURLs: [],
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [IngredientSection(items: [Ingredient(name: "豚肉", amount: "200g", isModified: true)])]
            ),
            stepSections: [CookingStepSection(items: [CookingStep(stepNumber: 1, instruction: "豚肉を切る", isModified: true)])]
        )
        state.previewRecipe = previewRecipe

        RecipeReducer.reduce(state: &state, action: .approveSubstitution)

        #expect(state.currentRecipe?.imageURLs == imageURLs)
        #expect(state.currentRecipe?.ingredientsInfo.allItems.first?.name == "豚肉")
        #expect(state.currentRecipe?.allSteps.first?.instruction == "豚肉を切る")
    }

    @Test
    func reduce_approveSubstitution_preservesRecipeID() {
        var state = RecipeState()
        let originalID = UUID()
        let originalRecipe = Recipe(
            id: originalID,
            title: "テスト料理",
            ingredientsInfo: Ingredients(sections: [IngredientSection(items: [Ingredient(name: "鶏肉", amount: "200g")])]),
            stepSections: [CookingStepSection(items: [CookingStep(stepNumber: 1, instruction: "鶏肉を切る")])]
        )
        state.currentRecipe = originalRecipe
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview

        let previewRecipe = Recipe(
            title: "テスト料理",
            ingredientsInfo: Ingredients(sections: [IngredientSection(items: [Ingredient(name: "豚肉", amount: "200g", isModified: true)])]),
            stepSections: [CookingStepSection(items: [CookingStep(stepNumber: 1, instruction: "豚肉を切る", isModified: true)])]
        )
        state.previewRecipe = previewRecipe

        RecipeReducer.reduce(state: &state, action: .approveSubstitution)

        #expect(state.currentRecipe?.id == originalID)
    }

    @Test
    func reduce_approveSubstitution_whenPreviewRecipeIsNil_doesNotOverwriteCurrentRecipe() {
        var state = RecipeState()
        let originalRecipe = makeSampleRecipe()
        state.currentRecipe = originalRecipe
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview
        state.previewRecipe = nil  // 異常ケース: プレビューがないのにapprove

        RecipeReducer.reduce(state: &state, action: .approveSubstitution)

        // currentRecipeが消えないことを確認
        #expect(state.currentRecipe == originalRecipe)
        // 他の状態は通常どおりリセットされる
        #expect(state.substitutionTarget == nil)
        #expect(state.previewRecipe == nil)
        #expect(state.originalRecipeSnapshot == nil)
        #expect(state.substitutionSheetMode == .input)
    }

    @Test
    func reduce_rejectSubstitution_discardsPreviewAndResetsState() {
        var state = RecipeState()
        let originalRecipe = makeSampleRecipe()
        state.currentRecipe = originalRecipe
        state.originalRecipeSnapshot = originalRecipe
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview

        let previewRecipe = Recipe(
            title: "テスト料理（更新後）",
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )
        state.previewRecipe = previewRecipe

        RecipeReducer.reduce(state: &state, action: .rejectSubstitution)

        // currentRecipeは変更されない
        #expect(state.currentRecipe == originalRecipe)
        #expect(state.substitutionTarget == nil)
        #expect(state.previewRecipe == nil)
        #expect(state.originalRecipeSnapshot == nil)
        #expect(state.substitutionSheetMode == .input)
    }

    @Test
    func reduce_requestAdditionalSubstitution_setsProcessingAndInputMode() {
        var state = RecipeState()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview
        state.previewRecipe = makeSampleRecipe()

        RecipeReducer.reduce(state: &state, action: .requestAdditionalSubstitution(prompt: "もっと辛くして"))

        #expect(state.isProcessingSubstitution == true)
        #expect(state.errorMessage == nil)
        #expect(state.substitutionSheetMode == .input)
    }

    @Test
    func reduce_closeSubstitutionSheet_resetsAllSubstitutionState() {
        var state = RecipeState()
        let originalRecipe = makeSampleRecipe()
        state.currentRecipe = originalRecipe
        state.originalRecipeSnapshot = originalRecipe
        state.previewRecipe = makeSampleRecipe()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.substitutionSheetMode = .preview

        RecipeReducer.reduce(state: &state, action: .closeSubstitutionSheet)

        #expect(state.substitutionTarget == nil)
        #expect(state.previewRecipe == nil)
        #expect(state.originalRecipeSnapshot == nil)
        #expect(state.substitutionSheetMode == .input)
        // currentRecipeは変更されない
        #expect(state.currentRecipe == originalRecipe)
    }

    @Test
    func reduce_loadRecipe_clearsExistingError() {
        var state = RecipeState()
        state.errorMessage = "前回のエラー"
        let url = URL(string: "https://example.com/recipe")!

        RecipeReducer.reduce(state: &state, action: .loadRecipe(url: url))

        #expect(state.errorMessage == nil)
        #expect(state.isLoadingRecipe == true)
    }

    // MARK: - Clear Tests

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = RecipeState()
        state.errorMessage = "エラーが発生しました"

        RecipeReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_clearRecipe_resetsAllState() {
        var state = RecipeState()
        state.currentRecipe = makeSampleRecipe()
        state.isLoadingRecipe = true
        state.isProcessingSubstitution = true
        state.errorMessage = "エラー"
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))

        RecipeReducer.reduce(state: &state, action: .clearRecipe)

        #expect(state.currentRecipe == nil)
        #expect(state.isLoadingRecipe == false)
        #expect(state.isProcessingSubstitution == false)
        #expect(state.errorMessage == nil)
        #expect(state.substitutionTarget == nil)
    }

    // MARK: - Model Tests

    @Test
    func recipe_equality() {
        let recipe1 = makeSampleRecipe()
        var recipe2 = makeSampleRecipe()

        // 同じIDなら等しくない（UUID()で都度生成されるので）
        #expect(recipe1 != recipe2)

        // 同じIDを設定すれば等しい
        let id = UUID()
        let recipe3 = Recipe(
            id: id,
            title: "テスト",
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )
        let recipe4 = Recipe(
            id: id,
            title: "テスト",
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )
        #expect(recipe3 == recipe4)
    }

    @Test
    func ingredient_equality() {
        let id = UUID()
        let ingredient1 = Ingredient(id: id, name: "鶏肉", amount: "200g")
        let ingredient2 = Ingredient(id: id, name: "鶏肉", amount: "200g")

        #expect(ingredient1 == ingredient2)
    }

    @Test
    func ingredient_withModified_notEqualToOriginal() {
        let id = UUID()
        let ingredient1 = Ingredient(id: id, name: "鶏肉", amount: "200g", isModified: false)
        let ingredient2 = Ingredient(id: id, name: "鶏肉", amount: "200g", isModified: true)

        #expect(ingredient1 != ingredient2)
    }

    @Test
    func cookingStep_equality() {
        let id = UUID()
        let step1 = CookingStep(id: id, stepNumber: 1, instruction: "切る")
        let step2 = CookingStep(id: id, stepNumber: 1, instruction: "切る")

        #expect(step1 == step2)
    }

    @Test
    func substitutionTarget_equality() {
        let id = UUID()
        let ingredient = Ingredient(id: id, name: "鶏肉", amount: "200g")
        let target1 = SubstitutionTarget.ingredient(ingredient)
        let target2 = SubstitutionTarget.ingredient(ingredient)

        #expect(target1 == target2)

        let step = CookingStep(id: id, stepNumber: 1, instruction: "切る")
        let target3 = SubstitutionTarget.step(step)

        #expect(target1 != target3)
    }

    // MARK: - Save Recipe Tests

    @Test
    func reduce_saveRecipe_doesNotChangeState() {
        var state = RecipeState()
        state.currentRecipe = makeSampleRecipe()
        let stateBefore = state

        RecipeReducer.reduce(state: &state, action: .saveRecipe)

        #expect(state == stateBefore)
    }

    @Test
    func reduce_recipeSaved_addsToSaved() {
        var state = RecipeState()
        let recipe = makeSampleRecipe()
        state.currentRecipe = recipe

        RecipeReducer.reduce(state: &state, action: .recipeSaved(recipe))

        #expect(state.savedRecipes.contains { $0.id == recipe.id })
    }

    @Test
    func reduce_recipeSaved_updatesExistingRecipe() {
        var state = RecipeState()
        let recipeID = UUID()
        let originalRecipe = Recipe(
            id: recipeID,
            title: "元のタイトル",
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )
        state.savedRecipes = [originalRecipe]

        let updatedRecipe = Recipe(
            id: recipeID,
            title: "更新後のタイトル",
            ingredientsInfo: Ingredients(sections: [IngredientSection(items: [Ingredient(name: "鶏肉", amount: "200g")])]),
            stepSections: []
        )

        RecipeReducer.reduce(state: &state, action: .recipeSaved(updatedRecipe))

        #expect(state.savedRecipes.count == 1)
        #expect(state.savedRecipes.first?.title == "更新後のタイトル")
        #expect(state.savedRecipes.first?.ingredientsInfo.allItems.count == 1)
    }

    @Test
    func reduce_recipeSaveFailed_setsError() {
        var state = RecipeState()

        RecipeReducer.reduce(state: &state, action: .recipeSaveFailed("保存に失敗しました"))

        #expect(state.errorMessage == "保存に失敗しました")
    }

    // MARK: - Load Saved Recipes Tests

    @Test
    func reduce_loadSavedRecipes_setsLoadingState() {
        var state = RecipeState()

        RecipeReducer.reduce(state: &state, action: .loadSavedRecipes)

        #expect(state.isLoadingSavedRecipes == true)
    }

    @Test
    func reduce_savedRecipesLoaded_setsRecipes() {
        var state = RecipeState()
        state.isLoadingSavedRecipes = true
        let recipes = [makeSampleRecipe(), makeSampleRecipe()]

        RecipeReducer.reduce(state: &state, action: .savedRecipesLoaded(recipes))

        #expect(state.isLoadingSavedRecipes == false)
        #expect(state.savedRecipes.count == 2)
    }

    @Test
    func reduce_savedRecipesLoadFailed_setsError() {
        var state = RecipeState()
        state.isLoadingSavedRecipes = true

        RecipeReducer.reduce(state: &state, action: .savedRecipesLoadFailed("読み込み失敗"))

        #expect(state.isLoadingSavedRecipes == false)
        #expect(state.errorMessage == "読み込み失敗")
    }

    // MARK: - Delete Recipe Tests

    @Test
    func reduce_deleteRecipe_setsDeletingState() {
        var state = RecipeState()
        let recipe = makeSampleRecipe()
        state.savedRecipes = [recipe]

        RecipeReducer.reduce(state: &state, action: .deleteRecipe(id: recipe.id))

        #expect(state.isDeletingRecipe == true)
    }

    @Test
    func reduce_recipeDeleted_removesFromSaved() {
        var state = RecipeState()
        let recipe = makeSampleRecipe()
        state.savedRecipes = [recipe]
        state.isDeletingRecipe = true

        RecipeReducer.reduce(state: &state, action: .recipeDeleted(id: recipe.id))

        #expect(state.isDeletingRecipe == false)
        #expect(!state.savedRecipes.contains { $0.id == recipe.id })
    }

    @Test
    func reduce_recipeDeleteFailed_setsError() {
        var state = RecipeState()
        state.isDeletingRecipe = true

        RecipeReducer.reduce(state: &state, action: .recipeDeleteFailed("削除に失敗"))

        #expect(state.isDeletingRecipe == false)
        #expect(state.errorMessage == "削除に失敗")
    }

    // MARK: - Select Saved Recipe Tests

    @Test
    func reduce_selectSavedRecipe_setsCurrent() {
        var state = RecipeState()
        let recipe = makeSampleRecipe()
        state.savedRecipes = [recipe]

        RecipeReducer.reduce(state: &state, action: .selectSavedRecipe(recipe))

        #expect(state.currentRecipe == recipe)
    }
}
