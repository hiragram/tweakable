import Foundation

// MARK: - ShoppingListDTO

/// 買い物リストのDTO（View用）
public struct ShoppingListDTO: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let updatedAt: Date
    public let recipeIDs: [UUID]
    public var items: [ShoppingListItemDTO]

    public init(
        id: UUID,
        name: String,
        createdAt: Date,
        updatedAt: Date,
        recipeIDs: [UUID],
        items: [ShoppingListItemDTO]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.recipeIDs = recipeIDs
        self.items = items
    }
}

// MARK: - ShoppingListItemDTO

/// 買い物アイテムのDTO（View用）
public struct ShoppingListItemDTO: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let totalAmount: String?
    public let category: String?
    public var isChecked: Bool
    public let breakdowns: [ShoppingListItemBreakdownDTO]

    public init(
        id: UUID,
        name: String,
        totalAmount: String?,
        category: String?,
        isChecked: Bool,
        breakdowns: [ShoppingListItemBreakdownDTO]
    ) {
        self.id = id
        self.name = name
        self.totalAmount = totalAmount
        self.category = category
        self.isChecked = isChecked
        self.breakdowns = breakdowns
    }
}

// MARK: - ShoppingListItemBreakdownDTO

/// 買い物アイテム内訳のDTO（View用）
public struct ShoppingListItemBreakdownDTO: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let amount: String?
    public let sourceRecipeID: UUID
    public let sourceRecipeTitle: String

    public init(
        id: UUID,
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
