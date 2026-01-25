import Foundation

/// レシピ画面のアクション
public enum RecipeAction: Sendable {
    // MARK: - Loading

    /// レシピを読み込む
    case loadRecipe(url: URL)

    /// レシピ読み込み成功
    case recipeLoaded(Recipe)

    /// レシピ読み込み失敗
    case recipeLoadFailed(String)

    // MARK: - Substitution Sheet

    /// 材料の置き換えシートを開く
    case openSubstitutionSheet(ingredient: Ingredient)

    /// 調理工程の置き換えシートを開く
    case openSubstitutionSheetForStep(step: CookingStep)

    /// 置き換えシートを閉じる
    case closeSubstitutionSheet

    // MARK: - Substitution Processing

    /// 置き換えをリクエスト
    case requestSubstitution(prompt: String)

    /// 置き換え完了
    case substitutionCompleted(Recipe)

    /// 置き換え失敗
    case substitutionFailed(String)

    // MARK: - Clear

    /// エラーをクリア
    case clearError

    /// レシピをクリア
    case clearRecipe
}
