import Foundation

/// 永続化が利用できない場合のNoOp実装
/// ModelContainer初期化失敗時のグレースフルデグラデーション用
public final class NoOpRecipePersistenceService: RecipePersistenceServiceProtocol, Sendable {
    public init() {}

    // MARK: - Recipe Operations

    public func saveRecipe(_ recipe: Recipe) async throws {
        // No-op: 永続化なしで動作
    }

    public func loadRecipe(id: UUID) async throws -> Recipe? {
        nil
    }

    public func loadAllRecipes() async throws -> [Recipe] {
        []
    }

    public func deleteRecipe(id: UUID) async throws {
        // No-op
    }

    // MARK: - ShoppingList Operations

    public func createShoppingList(name: String, recipeIDs: [UUID]) async throws -> ShoppingListDTO {
        // 空のリストを返す（永続化なし）
        ShoppingListDTO(
            id: UUID(),
            name: name,
            createdAt: Date(),
            updatedAt: Date(),
            recipeIDs: recipeIDs,
            items: []
        )
    }

    public func loadShoppingList(id: UUID) async throws -> ShoppingListDTO? {
        nil
    }

    public func loadAllShoppingLists() async throws -> [ShoppingListDTO] {
        []
    }

    public func addRecipeToShoppingList(listID: UUID, recipeID: UUID) async throws {
        // No-op
    }

    public func removeRecipeFromShoppingList(listID: UUID, recipeID: UUID) async throws {
        // No-op
    }

    public func deleteShoppingList(id: UUID) async throws {
        // No-op
    }

    public func updateShoppingItemChecked(itemID: UUID, isChecked: Bool) async throws {
        // No-op
    }

    // MARK: - Debug Operations

    public func deleteAllData() async throws {
        // No-op
    }
}
