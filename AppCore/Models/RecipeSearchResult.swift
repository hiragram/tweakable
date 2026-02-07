import Foundation

// MARK: - SearchMatchField

/// 検索でヒットしたフィールドを表すOptionSet
public struct SearchMatchField: OptionSet, Equatable, Sendable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// タイトルにヒット
    public static let title = SearchMatchField(rawValue: 1 << 0)
    /// 説明にヒット
    public static let description = SearchMatchField(rawValue: 1 << 1)
    /// 材料にヒット
    public static let ingredients = SearchMatchField(rawValue: 1 << 2)
    /// 工程にヒット
    public static let steps = SearchMatchField(rawValue: 1 << 3)
}

// MARK: - RecipeSearchResult

/// 検索結果のラッパー（Recipe + ヒット箇所情報）
public struct RecipeSearchResult: Equatable, Sendable, Identifiable {
    public var id: UUID { recipe.id }
    public let recipe: Recipe
    public let matchFields: SearchMatchField

    public init(recipe: Recipe, matchFields: SearchMatchField) {
        self.recipe = recipe
        self.matchFields = matchFields
    }
}
