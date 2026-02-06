import Foundation
import SwiftData

/// 永続化用の材料セクションモデル
@Model
public final class PersistedIngredientSection {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// セクション見出し（nilの場合は見出しなしで表示）
    public var header: String?

    /// セクションの並び順
    public var sortOrder: Int

    /// このセクションの材料リスト
    @Relationship(deleteRule: .cascade, inverse: \PersistedIngredient.section)
    public var ingredients: [PersistedIngredient]

    /// 属するレシピ（逆参照）
    public var recipe: PersistedRecipe?

    public init(
        id: UUID = UUID(),
        header: String? = nil,
        sortOrder: Int = 0,
        ingredients: [PersistedIngredient] = []
    ) {
        self.id = id
        self.header = header
        self.sortOrder = sortOrder
        self.ingredients = ingredients
    }
}
