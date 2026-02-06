import Foundation
import SwiftData

/// 永続化用の調理工程モデル
@Model
public final class PersistedCookingStep {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// 工程番号
    public var stepNumber: Int

    /// 調理手順の説明
    public var instruction: String

    /// 画像URL（JSON文字列として保存）
    /// SwiftDataはenumの配列を直接扱えないため、URL文字列の配列として保存
    public var imageURLStrings: [String]

    /// LLM APIによる置き換え処理で変更されたか
    public var isModified: Bool

    /// 工程の並び順（セクション内）
    public var sortOrder: Int

    /// 属するセクション（逆参照）
    public var section: PersistedCookingStepSection?

    public init(
        id: UUID = UUID(),
        stepNumber: Int,
        instruction: String,
        imageURLStrings: [String] = [],
        isModified: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.imageURLStrings = imageURLStrings
        self.isModified = isModified
        self.sortOrder = sortOrder
    }
}
