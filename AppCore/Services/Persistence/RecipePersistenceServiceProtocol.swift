import Foundation

/// レシピ永続化サービスのプロトコル
public protocol RecipePersistenceServiceProtocol: Sendable {
    // MARK: - Recipe Operations

    /// レシピを保存する
    func saveRecipe(_ recipe: Recipe) async throws

    /// 指定したIDのレシピを取得する
    func loadRecipe(id: UUID) async throws -> Recipe?

    /// 保存済みの全レシピを取得する
    func loadAllRecipes() async throws -> [Recipe]

    /// 指定したIDのレシピを削除する
    func deleteRecipe(id: UUID) async throws

    // MARK: - ShoppingList Operations

    /// 買い物リストを作成する
    func createShoppingList(name: String, recipeIDs: [UUID]) async throws -> ShoppingListDTO

    /// 指定したIDの買い物リストを取得する
    func loadShoppingList(id: UUID) async throws -> ShoppingListDTO?

    /// 全ての買い物リストを取得する
    func loadAllShoppingLists() async throws -> [ShoppingListDTO]

    /// 買い物リストにレシピを追加する
    func addRecipeToShoppingList(listID: UUID, recipeID: UUID) async throws

    /// 買い物リストからレシピを削除する
    func removeRecipeFromShoppingList(listID: UUID, recipeID: UUID) async throws

    /// 買い物リストを削除する
    func deleteShoppingList(id: UUID) async throws

    /// 買い物アイテムのチェック状態を更新する
    func updateShoppingItemChecked(itemID: UUID, isChecked: Bool) async throws
}
