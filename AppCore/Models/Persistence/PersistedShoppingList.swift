import Foundation
import SwiftData

/// 買い物リスト（複数のレシピを集約）
@Model
public final class PersistedShoppingList {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// 買い物リスト名
    public var name: String

    /// 作成日時
    public var createdAt: Date

    /// 更新日時
    public var updatedAt: Date

    /// 関連するレシピ（多対多）
    @Relationship(deleteRule: .nullify)
    public var recipes: [PersistedRecipe]

    /// 買い物アイテム（集約済み）
    @Relationship(deleteRule: .cascade, inverse: \PersistedShoppingListItem.shoppingList)
    public var items: [PersistedShoppingListItem]

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        recipes: [PersistedRecipe] = [],
        items: [PersistedShoppingListItem] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.recipes = recipes
        self.items = items
    }
}
