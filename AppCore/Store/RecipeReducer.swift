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
            state.originalRecipeSnapshot = state.currentRecipe
            state.substitutionSheetMode = .input

        case .openSubstitutionSheetForStep(let step):
            state.substitutionTarget = .step(step)
            state.originalRecipeSnapshot = state.currentRecipe
            state.substitutionSheetMode = .input

        case .closeSubstitutionSheet:
            state.substitutionTarget = nil
            state.previewRecipe = nil
            state.originalRecipeSnapshot = nil
            state.substitutionSheetMode = .input

        case .requestSubstitution:
            state.isProcessingSubstitution = true
            state.errorMessage = nil
            state.substitutionSheetMode = .input

        case .substitutionPreviewReady(let recipe):
            state.previewRecipe = recipe
            state.isProcessingSubstitution = false
            state.substitutionSheetMode = .preview

        case .substitutionFailed(let message):
            state.errorMessage = message
            state.isProcessingSubstitution = false
            // シートは閉じない（リトライ可能にする）

        case .approveSubstitution:
            // previewRecipeがnilの場合はcurrentRecipeを上書きしない（防御的コード）
            if let previewRecipe = state.previewRecipe {
                if let currentRecipe = state.currentRecipe {
                    // LLM結果にはimageURLsやidが含まれないため、元レシピから引き継ぐ
                    state.currentRecipe = previewRecipe.preservingIdentity(from: currentRecipe)
                } else {
                    state.currentRecipe = previewRecipe
                }
            }
            state.substitutionTarget = nil
            state.previewRecipe = nil
            state.originalRecipeSnapshot = nil
            state.substitutionSheetMode = .input

        case .rejectSubstitution:
            state.substitutionTarget = nil
            state.previewRecipe = nil
            state.originalRecipeSnapshot = nil
            state.substitutionSheetMode = .input

        case .requestAdditionalSubstitution:
            state.isProcessingSubstitution = true
            state.errorMessage = nil
            state.substitutionSheetMode = .input

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
            // 副作用のトリガーのみ（実際の保存処理はAppStore.handleRecipeSideEffects内）
            break

        case .recipeSaved(let recipe):
            // 既存のレシピを更新、なければ追加
            if let index = state.savedRecipes.firstIndex(where: { $0.id == recipe.id }) {
                state.savedRecipes[index] = recipe
            } else {
                state.savedRecipes.append(recipe)
            }

        case .recipeSaveFailed(let message):
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
