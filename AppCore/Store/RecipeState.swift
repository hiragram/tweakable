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

    public init() {}
}

// MARK: - SubstitutionTarget

/// 置き換え対象
public enum SubstitutionTarget: Equatable, Sendable {
    case ingredient(Ingredient)
    case step(CookingStep)
}
