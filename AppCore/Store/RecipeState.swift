import Foundation

// MARK: - RecipeState

/// レシピ画面の状態
public struct RecipeState: Equatable, Sendable {
    /// 現在表示中のレシピ（clearRecipeアクションまたは初期状態でnil）
    public var currentRecipe: Recipe?

    /// レシピ読み込み中かどうか（loadRecipeでtrue、recipeLoaded/recipeLoadFailedでfalse）
    public var isLoadingRecipe: Bool = false

    /// 置き換え処理中かどうか（requestSubstitution/requestAdditionalSubstitutionでtrue、substitutionPreviewReady/substitutionFailedでfalse）
    public var isProcessingSubstitution: Bool = false

    /// エラーメッセージ（recipeLoadFailed/substitutionFailedで設定、loadRecipe/requestSubstitution/clearErrorでクリア）
    public var errorMessage: String?

    /// 置き換え対象（シート表示制御、openSubstitutionSheetで設定、closeSubstitutionSheet/approveSubstitution/rejectSubstitutionでnil）
    public var substitutionTarget: SubstitutionTarget?

    // MARK: - Substitution Preview State

    /// プレビュー中のレシピ（LLM結果を一時保持、承認前）
    public var previewRecipe: Recipe?

    /// 置き換え前のレシピのスナップショット（差分比較用）
    public var originalRecipeSnapshot: Recipe?

    /// 置き換えシートの表示モード
    public var substitutionSheetMode: SubstitutionSheetMode = .input

    // MARK: - Persistence State

    /// 保存済みレシピ一覧
    public var savedRecipes: [Recipe] = []

    /// 保存済みレシピを読み込み中かどうか
    public var isLoadingSavedRecipes: Bool = false

    /// レシピ削除中かどうか
    public var isDeletingRecipe: Bool = false

    // MARK: - Category State

    /// 全カテゴリ一覧
    public var categories: [RecipeCategory] = []

    /// カテゴリとレシピの紐付け（カテゴリID → レシピIDのセット）
    public var categoryRecipeMap: [UUID: Set<UUID>] = [:]

    /// カテゴリ読み込み中かどうか
    public var isLoadingCategories: Bool = false

    /// 現在選択中のカテゴリフィルタ（nilなら全レシピ表示）
    public var selectedCategoryFilter: UUID? = nil

    // MARK: - Search State

    /// 検索クエリ（空文字列で検索非アクティブ）
    public var searchQuery: String = ""

    /// 検索結果画面でのカテゴリフィルタ（nilなら全検索結果表示）
    public var selectedSearchCategoryFilter: UUID? = nil

    public init() {}
}

// MARK: - Category Computed Properties

extension RecipeState {
    /// フィルタ適用後のレシピ一覧
    public var filteredRecipes: [Recipe] {
        guard let categoryID = selectedCategoryFilter else {
            return savedRecipes
        }
        let recipeIDs = categoryRecipeMap[categoryID] ?? []
        return savedRecipes.filter { recipeIDs.contains($0.id) }
    }

    // MARK: - Search Computed Properties

    /// 検索がアクティブかどうか
    public var isSearchActive: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 検索結果（全カテゴリ、カテゴリフィルタ適用前）
    public var searchResults: [RecipeSearchResult] {
        guard isSearchActive else { return [] }
        return RecipeSearchHelper.searchResults(recipes: savedRecipes, query: searchQuery)
    }

    /// カテゴリフィルタ適用後の検索結果
    public var searchFilteredResults: [RecipeSearchResult] {
        RecipeSearchHelper.filteredResults(
            results: searchResults,
            categoryID: selectedSearchCategoryFilter,
            categoryRecipeMap: categoryRecipeMap
        )
    }

    /// 検索結果における各カテゴリの件数
    public var searchResultCategoryCounts: [UUID: Int] {
        RecipeSearchHelper.categoryCounts(results: searchResults, categoryRecipeMap: categoryRecipeMap)
    }

    /// どのカテゴリにも属さないレシピ
    public var uncategorizedRecipes: [Recipe] {
        let allCategorizedIDs = Set(categoryRecipeMap.values.flatMap { $0 })
        return savedRecipes.filter { !allCategorizedIDs.contains($0.id) }
    }
}

// MARK: - SubstitutionTarget

/// 置き換え対象
public enum SubstitutionTarget: Equatable, Sendable {
    case ingredient(Ingredient)
    case step(CookingStep)
}

// MARK: - SubstitutionSheetMode

/// 置き換えシートのモード
public enum SubstitutionSheetMode: Equatable, Sendable {
    /// 入力モード（初期、追加指示入力時）
    case input
    /// プレビューモード（LLM結果表示中）
    case preview
}
