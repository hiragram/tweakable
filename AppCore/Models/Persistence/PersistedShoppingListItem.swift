import Foundation
import SwiftData

/// 買い物リストのアイテム（集約後）
@Model
public final class PersistedShoppingListItem {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// 材料名
    public var name: String

    /// 合算された分量（例: "500g"）
    public var totalAmount: String?

    /// カテゴリ（野菜、肉、調味料など）
    public var category: String?

    /// チェック済みかどうか
    public var isChecked: Bool

    /// 内訳（どのレシピからいくつ必要か）
    @Relationship(deleteRule: .cascade, inverse: \PersistedShoppingListItemBreakdown.shoppingListItem)
    public var breakdowns: [PersistedShoppingListItemBreakdown]

    /// 属する買い物リスト（逆参照）
    public var shoppingList: PersistedShoppingList?

    public init(
        id: UUID = UUID(),
        name: String,
        totalAmount: String? = nil,
        category: String? = nil,
        isChecked: Bool = false,
        breakdowns: [PersistedShoppingListItemBreakdown] = []
    ) {
        self.id = id
        self.name = name
        self.totalAmount = totalAmount
        self.category = category
        self.isChecked = isChecked
        self.breakdowns = breakdowns
    }
}
