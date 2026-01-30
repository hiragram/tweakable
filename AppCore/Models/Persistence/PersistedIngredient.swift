import Foundation
import SwiftData

/// 永続化用の材料モデル
@Model
public final class PersistedIngredient {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// 材料名
    public var name: String

    /// 分量（例: "2個", "大さじ1"）
    public var amount: String?

    /// LLM APIによる置き換え処理で変更されたか
    public var isModified: Bool

    /// 属するレシピ（逆参照）
    public var recipe: PersistedRecipe?

    public init(
        id: UUID = UUID(),
        name: String,
        amount: String? = nil,
        isModified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.isModified = isModified
    }
}
