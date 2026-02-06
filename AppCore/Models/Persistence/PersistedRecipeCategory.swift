import Foundation
import SwiftData

/// 永続化用のレシピカテゴリモデル
@Model
public final class PersistedRecipeCategory {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// カテゴリ名
    public var name: String

    /// 作成日時
    public var createdAt: Date

    /// このカテゴリに属するレシピ（多対多）
    @Relationship(deleteRule: .nullify, inverse: \PersistedRecipe.categories)
    public var recipes: [PersistedRecipe]

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        recipes: [PersistedRecipe] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.recipes = recipes
    }
}

// MARK: - Domain Conversion

extension PersistedRecipeCategory {
    /// 永続化モデルからドメインモデルへ変換
    public func toDomain() -> RecipeCategory {
        RecipeCategory(
            id: id,
            name: name,
            createdAt: createdAt
        )
    }
}
