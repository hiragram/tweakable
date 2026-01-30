import Foundation

/// レシピ画面のReducer（純粋関数）
public enum RecipeReducer {
    /// 状態を更新する
    public static func reduce(state: inout RecipeState, action: RecipeAction) {
        switch action {
        case .loadRecipe:
            state.isLoadingRecipe = true
            state.errorMessage = nil

        case .recipeLoaded(let recipe):
            state.currentRecipe = recipe
            state.isLoadingRecipe = false

        case .recipeLoadFailed(let message):
            state.errorMessage = message
            state.isLoadingRecipe = false

        case .openSubstitutionSheet(let ingredient):
            state.substitutionTarget = .ingredient(ingredient)

        case .openSubstitutionSheetForStep(let step):
            state.substitutionTarget = .step(step)

        case .closeSubstitutionSheet:
            state.substitutionTarget = nil

        case .requestSubstitution:
            state.isProcessingSubstitution = true
            state.errorMessage = nil

        case .substitutionCompleted(let recipe):
            state.currentRecipe = recipe
            state.isProcessingSubstitution = false
            state.substitutionTarget = nil

        case .substitutionFailed(let message):
            state.errorMessage = message
            state.isProcessingSubstitution = false
            // シートは閉じない（リトライ可能にする）

        case .clearError:
            state.errorMessage = nil

        case .clearRecipe:
            state.currentRecipe = nil
            state.isLoadingRecipe = false
            state.isProcessingSubstitution = false
            state.errorMessage = nil
            state.substitutionTarget = nil

        // MARK: - Persistence

        case .saveRecipe:
            state.isSavingRecipe = true

        case .recipeSaved(let recipe):
            state.isSavingRecipe = false
            // 既存のレシピを更新、なければ追加
            if let index = state.savedRecipes.firstIndex(where: { $0.id == recipe.id }) {
                state.savedRecipes[index] = recipe
            } else {
                state.savedRecipes.append(recipe)
            }

        case .recipeSaveFailed(let message):
            state.isSavingRecipe = false
            state.errorMessage = message

        case .loadSavedRecipes:
            state.isLoadingSavedRecipes = true

        case .savedRecipesLoaded(let recipes):
            state.isLoadingSavedRecipes = false
            state.savedRecipes = recipes

        case .savedRecipesLoadFailed(let message):
            state.isLoadingSavedRecipes = false
            state.errorMessage = message

        case .deleteRecipe:
            state.isDeletingRecipe = true

        case .recipeDeleted(let id):
            state.isDeletingRecipe = false
            state.savedRecipes.removeAll { $0.id == id }

        case .selectSavedRecipe(let recipe):
            state.currentRecipe = recipe

        case .recipeDeleteFailed(let message):
            state.isDeletingRecipe = false
            state.errorMessage = message
        }
    }
}
