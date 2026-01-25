import Foundation

// MARK: - RecipeState

/// レシピ画面の状態
public struct RecipeState: Equatable, Sendable {
    /// 現在表示中のレシピ
    public var currentRecipe: Recipe?

    /// レシピ読み込み中かどうか
    public var isLoadingRecipe: Bool = false

    /// 置き換え処理中かどうか
    public var isProcessingSubstitution: Bool = false

    /// エラーメッセージ
    public var errorMessage: String?

    /// 置き換え対象（シート表示用）
    public var substitutionTarget: SubstitutionTarget?

    public init() {}
}

// MARK: - SubstitutionTarget

/// 置き換え対象
public enum SubstitutionTarget: Equatable, Sendable {
    case ingredient(Ingredient)
    case step(CookingStep)
}
