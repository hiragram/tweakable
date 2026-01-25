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
            state.substitutionTarget = nil  // シートを閉じる

        case .clearError:
            state.errorMessage = nil

        case .clearRecipe:
            state.currentRecipe = nil
            state.isLoadingRecipe = false
            state.isProcessingSubstitution = false
            state.errorMessage = nil
            state.substitutionTarget = nil
        }
    }
}
