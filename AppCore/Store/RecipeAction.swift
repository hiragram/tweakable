import Foundation

/// レシピ画面のアクション
///
/// ## アクションフロー
/// - レシピ読み込み: loadRecipe → (recipeLoaded | recipeLoadFailed)
/// - 置き換え処理: openSubstitutionSheet/openSubstitutionSheetForStep → requestSubstitution → (substitutionCompleted | substitutionFailed)
///
/// ## 副作用を持つアクション
/// - loadRecipe: LLM APIを呼び出してURLからレシピを抽出
/// - requestSubstitution: LLM APIを呼び出して食材/工程を置き換え
public enum RecipeAction: Sendable {
    // MARK: - Loading

    /// レシピを読み込む（副作用: LLM API呼び出し → recipeLoaded or recipeLoadFailed）
    case loadRecipe(url: URL)

    /// レシピ読み込み成功（loadRecipeの結果）
    case recipeLoaded(Recipe)

    /// レシピ読み込み失敗（loadRecipeの結果）
    case recipeLoadFailed(String)

    // MARK: - Substitution Sheet

    /// 材料の置き換えシートを開く
    case openSubstitutionSheet(ingredient: Ingredient)

    /// 調理工程の置き換えシートを開く
    case openSubstitutionSheetForStep(step: CookingStep)

    /// 置き換えシートを閉じる
    case closeSubstitutionSheet

    // MARK: - Substitution Processing

    /// 置き換えをリクエスト（副作用: LLM API呼び出し → substitutionCompleted or substitutionFailed）
    case requestSubstitution(prompt: String)

    /// 置き換え完了（requestSubstitutionの結果、シートを閉じる）
    case substitutionCompleted(Recipe)

    /// 置き換え失敗（requestSubstitutionの結果、シートを閉じる）
    case substitutionFailed(String)

    // MARK: - Clear

    /// エラーをクリア
    case clearError

    /// レシピをクリア
    case clearRecipe

    // MARK: - Persistence

    /// レシピを保存（副作用: PersistenceService呼び出し → recipeSaved or recipeSaveFailed）
    case saveRecipe

    /// レシピ保存成功（saveRecipeの結果）
    case recipeSaved(Recipe)

    /// レシピ保存失敗（saveRecipeの結果）
    case recipeSaveFailed(String)

    /// 保存済みレシピ一覧を読み込む（副作用: PersistenceService呼び出し → savedRecipesLoaded or savedRecipesLoadFailed）
    case loadSavedRecipes

    /// 保存済みレシピ読み込み成功（loadSavedRecipesの結果）
    case savedRecipesLoaded([Recipe])

    /// 保存済みレシピ読み込み失敗（loadSavedRecipesの結果）
    case savedRecipesLoadFailed(String)

    /// レシピを削除（副作用: PersistenceService呼び出し → recipeDeleted or recipeDeleteFailed）
    case deleteRecipe(id: UUID)

    /// レシピ削除成功（deleteRecipeの結果）
    case recipeDeleted(id: UUID)

    /// レシピ削除失敗（deleteRecipeの結果）
    case recipeDeleteFailed(String)

    /// 保存済みレシピを選択して表示
    case selectSavedRecipe(Recipe)
}
