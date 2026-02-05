import Foundation

// MARK: - RecipeCategory

/// レシピカテゴリ（ユーザーが自由に作成・命名可能）
public struct RecipeCategory: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}
