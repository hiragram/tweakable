import Foundation

/// レシピ画面のアクション
///
/// ## アクションフロー
/// - レシピ読み込み: loadRecipe → (recipeLoaded | recipeLoadFailed)
/// - 置き換え処理: openSubstitutionSheet/openSubstitutionSheetForStep → requestSubstitution → (substitutionPreviewReady | substitutionFailed) → (approveSubstitution | rejectSubstitution | requestAdditionalSubstitution)
///
/// ## 副作用を持つアクション
/// - loadRecipe: LLM APIを呼び出してURLからレシピを抽出
/// - requestSubstitution: LLM APIを呼び出して食材/工程を置き換え
/// - requestAdditionalSubstitution: LLM APIを呼び出して追加の置き換え指示を処理
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

    /// 置き換えをリクエスト（副作用: LLM API呼び出し → substitutionPreviewReady or substitutionFailed）
    case requestSubstitution(prompt: String)

    /// 置き換え結果のプレビュー準備完了（requestSubstitutionの結果、プレビューモードに遷移）
    case substitutionPreviewReady(Recipe)

    /// 置き換え失敗（requestSubstitutionの結果）
    case substitutionFailed(String)

    // MARK: - Substitution Confirmation

    /// 置き換えを承認（currentRecipeを更新してシートを閉じる）
    case approveSubstitution

    /// 置き換えを却下（プレビューを破棄してシートを閉じる）
    case rejectSubstitution

    /// 追加の置き換え指示をリクエスト（副作用: LLM API呼び出し → substitutionPreviewReady or substitutionFailed）
    case requestAdditionalSubstitution(prompt: String)

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

    // MARK: - Category CRUD

    /// カテゴリ一覧を読み込む（副作用: PersistenceService呼び出し → categoriesLoaded or categoriesLoadFailed）
    case loadCategories

    /// カテゴリ読み込み成功
    case categoriesLoaded([RecipeCategory], categoryRecipeMap: [UUID: Set<UUID>])

    /// カテゴリ読み込み失敗
    case categoriesLoadFailed(String)

    /// カテゴリを作成する（副作用: PersistenceService呼び出し → categoryCreated or categoryCreateFailed）
    case createCategory(name: String)

    /// カテゴリ作成成功
    case categoryCreated(RecipeCategory)

    /// カテゴリ作成失敗
    case categoryCreateFailed(String)

    /// カテゴリ名を変更する（副作用: PersistenceService呼び出し → categoryRenamed or categoryRenameFailed）
    case renameCategory(id: UUID, newName: String)

    /// カテゴリ名変更成功
    case categoryRenamed(RecipeCategory)

    /// カテゴリ名変更失敗
    case categoryRenameFailed(String)

    /// カテゴリを削除する（副作用: PersistenceService呼び出し → categoryDeleted or categoryDeleteFailed）
    case deleteCategory(id: UUID)

    /// カテゴリ削除成功
    case categoryDeleted(id: UUID)

    /// カテゴリ削除失敗
    case categoryDeleteFailed(String)

    // MARK: - Recipe ↔ Category

    /// レシピをカテゴリに追加する（副作用: PersistenceService呼び出し → recipeCategoryUpdated or recipeCategoryUpdateFailed）
    case addRecipeToCategory(recipeID: UUID, categoryID: UUID)

    /// レシピをカテゴリから削除する（副作用: PersistenceService呼び出し → recipeCategoryUpdated or recipeCategoryUpdateFailed）
    case removeRecipeFromCategory(recipeID: UUID, categoryID: UUID)

    /// レシピのカテゴリ紐付け更新成功
    case recipeCategoryUpdated(recipeID: UUID, categoryID: UUID, added: Bool)

    /// レシピのカテゴリ紐付け更新失敗
    case recipeCategoryUpdateFailed(String)

    // MARK: - Category Filter

    /// カテゴリフィルタを変更
    case selectCategoryFilter(UUID?)

    // MARK: - Search

    /// 検索クエリを更新（selectedSearchCategoryFilterもリセット）
    case updateSearchQuery(String)

    /// 検索結果画面のカテゴリフィルタを変更
    case selectSearchCategoryFilter(UUID?)
}
