import Foundation

// MARK: - Recipe

/// レシピデータ
public struct Recipe: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let imageURLs: [URL]
    public var ingredientsInfo: Ingredients
    public var steps: [CookingStep]
    public let sourceURL: URL?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        imageURLs: [URL] = [],
        ingredientsInfo: Ingredients,
        steps: [CookingStep],
        sourceURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURLs = imageURLs
        self.ingredientsInfo = ingredientsInfo
        self.steps = steps
        self.sourceURL = sourceURL
    }
}

// MARK: - Ingredients

/// 材料情報
public struct Ingredients: Equatable, Sendable {
    /// 何人分の材料か
    public let servings: String?
    /// 材料リスト
    public var items: [Ingredient]

    public init(
        servings: String? = nil,
        items: [Ingredient]
    ) {
        self.servings = servings
        self.items = items
    }
}

// MARK: - Ingredient

/// 材料
public struct Ingredient: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let amount: String?
    public var isModified: Bool

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

// MARK: - CookingStep

/// 調理工程
public struct CookingStep: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let stepNumber: Int
    public let instruction: String
    public let imageURLs: [URL]
    public var isModified: Bool

    public init(
        id: UUID = UUID(),
        stepNumber: Int,
        instruction: String,
        imageURLs: [URL] = [],
        isModified: Bool = false
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.imageURLs = imageURLs
        self.isModified = isModified
    }
}
