import Foundation
import SwiftData

/// 買い物アイテムの内訳（どのレシピからいくつ必要か）
@Model
public final class PersistedShoppingListItemBreakdown {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// 分量（例: "200g"）
    public var amount: String?

    /// 元のレシピID
    public var sourceRecipeID: UUID

    /// 元のレシピ名（表示用）
    public var sourceRecipeTitle: String

    /// 属する買い物アイテム（逆参照）
    public var shoppingListItem: PersistedShoppingListItem?

    public init(
        id: UUID = UUID(),
        amount: String?,
        sourceRecipeID: UUID,
        sourceRecipeTitle: String
    ) {
        self.id = id
        self.amount = amount
        self.sourceRecipeID = sourceRecipeID
        self.sourceRecipeTitle = sourceRecipeTitle
    }
}
