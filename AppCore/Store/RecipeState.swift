import Foundation

// MARK: - RecipeState

/// レシピ画面の状態
public struct RecipeState: Equatable, Sendable {
    /// 現在表示中のレシピ（clearRecipeアクションまたは初期状態でnil）
    public var currentRecipe: Recipe?

    /// レシピ読み込み中かどうか（loadRecipeでtrue、recipeLoaded/recipeLoadFailedでfalse）
    public var isLoadingRecipe: Bool = false

    /// 置き換え処理中かどうか（requestSubstitutionでtrue、substitutionCompleted/substitutionFailedでfalse）
    public var isProcessingSubstitution: Bool = false

    /// エラーメッセージ（recipeLoadFailed/substitutionFailedで設定、loadRecipe/requestSubstitution/clearErrorでクリア）
    public var errorMessage: String?

    /// 置き換え対象（シート表示制御、openSubstitutionSheetで設定、closeSubstitutionSheet/substitutionCompleted/substitutionFailedでnil）
    public var substitutionTarget: SubstitutionTarget?

    // MARK: - Persistence State

    /// 保存済みレシピ一覧
    public var savedRecipes: [Recipe] = []

    /// 保存済みレシピを読み込み中かどうか
    public var isLoadingSavedRecipes: Bool = false

    /// レシピ保存中かどうか
    public var isSavingRecipe: Bool = false

    /// レシピ削除中かどうか
    public var isDeletingRecipe: Bool = false

    public init() {}
}

// MARK: - SubstitutionTarget

/// 置き換え対象
public enum SubstitutionTarget: Equatable, Sendable {
    case ingredient(Ingredient)
    case step(CookingStep)
}
