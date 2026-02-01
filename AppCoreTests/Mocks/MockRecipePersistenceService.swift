import Foundation
@testable import AppCore

/// テスト用のRecipePersistenceServiceモック
public final class MockRecipePersistenceService: RecipePersistenceServiceProtocol, @unchecked Sendable {
    // MARK: - Recipe Storage

    public var savedRecipes: [UUID: Recipe] = [:]
    public var shoppingLists: [UUID: ShoppingListDTO] = [:]

    // MARK: - Call Tracking

    public var saveRecipeCallCount = 0
    public var loadRecipeCallCount = 0
    public var loadAllRecipesCallCount = 0
    public var deleteRecipeCallCount = 0
    public var createShoppingListCallCount = 0
    public var loadShoppingListCallCount = 0
    public var loadAllShoppingListsCallCount = 0
    public var deleteShoppingListCallCount = 0
    public var updateShoppingItemCheckedCallCount = 0

    // MARK: - Error Control

    public var errorToThrow: Error?

    public init() {}

    // MARK: - Recipe Operations

    public func saveRecipe(_ recipe: Recipe) async throws {
        saveRecipeCallCount += 1
        if let error = errorToThrow { throw error }
        savedRecipes[recipe.id] = recipe
    }

    public func loadRecipe(id: UUID) async throws -> Recipe? {
        loadRecipeCallCount += 1
        if let error = errorToThrow { throw error }
        return savedRecipes[id]
    }

    public func loadAllRecipes() async throws -> [Recipe] {
        loadAllRecipesCallCount += 1
        if let error = errorToThrow { throw error }
        return Array(savedRecipes.values)
    }

    public func deleteRecipe(id: UUID) async throws {
        deleteRecipeCallCount += 1
        if let error = errorToThrow { throw error }
        savedRecipes.removeValue(forKey: id)
    }

    // MARK: - ShoppingList Operations

    public func createShoppingList(name: String, recipeIDs: [UUID]) async throws -> ShoppingListDTO {
        createShoppingListCallCount += 1
        if let error = errorToThrow { throw error }

        let id = UUID()
        let now = Date()
        let list = ShoppingListDTO(
            id: id,
            name: name,
            createdAt: now,
            updatedAt: now,
            recipeIDs: recipeIDs,
            items: []
        )
        shoppingLists[id] = list
        return list
    }

    public func loadShoppingList(id: UUID) async throws -> ShoppingListDTO? {
        loadShoppingListCallCount += 1
        if let error = errorToThrow { throw error }
        return shoppingLists[id]
    }

    public func loadAllShoppingLists() async throws -> [ShoppingListDTO] {
        loadAllShoppingListsCallCount += 1
        if let error = errorToThrow { throw error }
        return Array(shoppingLists.values)
    }

    public func addRecipeToShoppingList(listID: UUID, recipeID: UUID) async throws {
        if let error = errorToThrow { throw error }
        guard var list = shoppingLists[listID] else { return }
        var recipeIDs = list.recipeIDs
        recipeIDs.append(recipeID)
        shoppingLists[listID] = ShoppingListDTO(
            id: list.id,
            name: list.name,
            createdAt: list.createdAt,
            updatedAt: Date(),
            recipeIDs: recipeIDs,
            items: list.items
        )
    }

    public func removeRecipeFromShoppingList(listID: UUID, recipeID: UUID) async throws {
        if let error = errorToThrow { throw error }
        guard var list = shoppingLists[listID] else { return }
        var recipeIDs = list.recipeIDs
        recipeIDs.removeAll { $0 == recipeID }
        shoppingLists[listID] = ShoppingListDTO(
            id: list.id,
            name: list.name,
            createdAt: list.createdAt,
            updatedAt: Date(),
            recipeIDs: recipeIDs,
            items: list.items
        )
    }

    public func deleteShoppingList(id: UUID) async throws {
        deleteShoppingListCallCount += 1
        if let error = errorToThrow { throw error }
        shoppingLists.removeValue(forKey: id)
    }

    public func updateShoppingItemChecked(itemID: UUID, isChecked: Bool) async throws {
        updateShoppingItemCheckedCallCount += 1
        if let error = errorToThrow { throw error }
        // Mockでは実際の更新は行わない
    }

    // MARK: - Debug Operations

    public var deleteAllDataCallCount = 0

    public func deleteAllData() async throws {
        deleteAllDataCallCount += 1
        if let error = errorToThrow { throw error }
        savedRecipes.removeAll()
        shoppingLists.removeAll()
    }
}
