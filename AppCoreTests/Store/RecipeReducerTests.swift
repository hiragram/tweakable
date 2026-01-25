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
                items: [
                    Ingredient(name: "鶏肉", amount: "200g"),
                    Ingredient(name: "塩", amount: "少々")
                ]
            ),
            steps: [
                CookingStep(stepNumber: 1, instruction: "鶏肉を切る"),
                CookingStep(stepNumber: 2, instruction: "塩をふる")
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
    func reduce_substitutionCompleted_updatesRecipeAndClosesSheet() {
        var state = RecipeState()
        state.currentRecipe = makeSampleRecipe()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.isProcessingSubstitution = true

        let updatedRecipe = Recipe(
            title: "テスト料理",
            ingredientsInfo: Ingredients(
                servings: "2人分",
                items: [
                    Ingredient(name: "豚肉", amount: "200g", isModified: true),
                    Ingredient(name: "塩", amount: "少々")
                ]
            ),
            steps: [
                CookingStep(stepNumber: 1, instruction: "豚肉を切る", isModified: true),
                CookingStep(stepNumber: 2, instruction: "塩をふる")
            ]
        )

        RecipeReducer.reduce(state: &state, action: .substitutionCompleted(updatedRecipe))

        #expect(state.currentRecipe == updatedRecipe)
        #expect(state.isProcessingSubstitution == false)
        #expect(state.substitutionTarget == nil)
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
    func reduce_substitutionFailed_closesSheet() {
        var state = RecipeState()
        state.substitutionTarget = .ingredient(Ingredient(name: "鶏肉", amount: "200g"))
        state.isProcessingSubstitution = true

        RecipeReducer.reduce(state: &state, action: .substitutionFailed("エラー"))

        #expect(state.substitutionTarget == nil)
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
        state.isLoadingRecipe = false
        state.isProcessingSubstitution = false
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
            ingredientsInfo: Ingredients(items: []),
            steps: []
        )
        let recipe4 = Recipe(
            id: id,
            title: "テスト",
            ingredientsInfo: Ingredients(items: []),
            steps: []
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
}
