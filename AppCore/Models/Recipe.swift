import Foundation

// MARK: - Recipe

/// レシピデータ
public struct Recipe: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let imageURLs: [ImageSource]
    public var ingredientsInfo: Ingredients
    public var stepSections: [CookingStepSection]
    public let sourceURL: URL?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        imageURLs: [ImageSource] = [],
        ingredientsInfo: Ingredients,
        stepSections: [CookingStepSection],
        sourceURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURLs = imageURLs
        self.ingredientsInfo = ingredientsInfo
        self.stepSections = stepSections
        self.sourceURL = sourceURL
    }

    /// 全調理工程をフラットに取得（セクション構造を無視してフラットリストが必要な場合に使用）
    public var allSteps: [CookingStep] {
        stepSections.flatMap { $0.items }
    }

    /// LLM置き換え結果に元レシピのIDと画像URLを引き継ぐ
    public func preservingIdentity(from original: Recipe) -> Recipe {
        Recipe(
            id: original.id,
            title: title,
            description: description,
            imageURLs: original.imageURLs,
            ingredientsInfo: ingredientsInfo,
            stepSections: stepSections,
            sourceURL: sourceURL
        )
    }
}

// MARK: - Ingredients

/// 材料情報
public struct Ingredients: Equatable, Sendable {
    /// 何人分の材料か
    public let servings: String?
    /// 材料セクションリスト
    public var sections: [IngredientSection]

    public init(
        servings: String? = nil,
        sections: [IngredientSection]
    ) {
        self.servings = servings
        self.sections = sections
    }

    /// 全材料をフラットに取得（セクション構造を無視してフラットリストが必要な場合に使用）
    public var allItems: [Ingredient] {
        sections.flatMap { $0.items }
    }
}

// MARK: - IngredientSection

/// 材料セクション
public struct IngredientSection: Equatable, Sendable, Identifiable {
    public let id: UUID
    /// セクション見出し（nilの場合は見出しなしで表示）
    public let header: String?
    /// このセクションの材料リスト
    public var items: [Ingredient]

    public init(
        id: UUID = UUID(),
        header: String? = nil,
        items: [Ingredient]
    ) {
        self.id = id
        self.header = header
        self.items = items
    }
}

// MARK: - Ingredient

/// 材料
public struct Ingredient: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let amount: String?
    /// LLM APIによる置き換え処理で変更されたかどうか
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

// MARK: - CookingStepSection

/// 調理工程セクション
public struct CookingStepSection: Equatable, Sendable, Identifiable {
    public let id: UUID
    /// セクション見出し（nilの場合は見出しなしで表示）
    public let header: String?
    /// このセクションの調理工程リスト
    public var items: [CookingStep]

    public init(
        id: UUID = UUID(),
        header: String? = nil,
        items: [CookingStep]
    ) {
        self.id = id
        self.header = header
        self.items = items
    }
}

// MARK: - CookingStep

/// 調理工程
public struct CookingStep: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let stepNumber: Int
    public let instruction: String
    public let imageURLs: [ImageSource]
    /// LLM APIによる置き換え処理で変更されたかどうか
    public var isModified: Bool

    public init(
        id: UUID = UUID(),
        stepNumber: Int,
        instruction: String,
        imageURLs: [ImageSource] = [],
        isModified: Bool = false
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.imageURLs = imageURLs
        self.isModified = isModified
    }
}
