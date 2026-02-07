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
        let query = searchQuery.lowercased()
        return savedRecipes.compactMap { recipe in
            var matchFields = SearchMatchField()

            if recipe.title.lowercased().contains(query) {
                matchFields.insert(.title)
            }
            if let desc = recipe.description, desc.lowercased().contains(query) {
                matchFields.insert(.description)
            }
            if recipe.ingredientsInfo.allItems.contains(where: { $0.name.lowercased().contains(query) }) {
                matchFields.insert(.ingredients)
            }
            if recipe.allSteps.contains(where: { $0.instruction.lowercased().contains(query) }) {
                matchFields.insert(.steps)
            }

            return matchFields.isEmpty ? nil : RecipeSearchResult(recipe: recipe, matchFields: matchFields)
        }
    }

    /// カテゴリフィルタ適用後の検索結果
    public var searchFilteredResults: [RecipeSearchResult] {
        guard let categoryID = selectedSearchCategoryFilter else {
            return searchResults
        }
        let recipeIDs = categoryRecipeMap[categoryID] ?? []
        return searchResults.filter { recipeIDs.contains($0.recipe.id) }
    }

    /// 検索結果における各カテゴリの件数
    public var searchResultCategoryCounts: [UUID: Int] {
        let resultIDs = Set(searchResults.map { $0.recipe.id })
        var counts: [UUID: Int] = [:]
        for (categoryID, recipeIDs) in categoryRecipeMap {
            counts[categoryID] = recipeIDs.intersection(resultIDs).count
        }
        return counts
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
