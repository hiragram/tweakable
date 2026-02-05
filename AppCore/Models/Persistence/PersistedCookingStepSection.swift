import Foundation
import SwiftData

/// 永続化用の調理工程セクションモデル
@Model
public final class PersistedCookingStepSection {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// セクション見出し（nilの場合は見出しなしで表示）
    public var header: String?

    /// セクションの並び順
    public var sortOrder: Int

    /// このセクションの調理工程リスト
    @Relationship(deleteRule: .cascade, inverse: \PersistedCookingStep.section)
    public var steps: [PersistedCookingStep]

    /// 属するレシピ（逆参照）
    public var recipe: PersistedRecipe?

    public init(
        id: UUID = UUID(),
        header: String? = nil,
        sortOrder: Int = 0,
        steps: [PersistedCookingStep] = []
    ) {
        self.id = id
        self.header = header
        self.sortOrder = sortOrder
        self.steps = steps
    }
}
