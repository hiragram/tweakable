import Foundation

/// 買い物リスト機能のアクション
///
/// ## アクションフロー
/// - リスト一覧読み込み: loadShoppingLists → (shoppingListsLoaded | shoppingListsLoadFailed)
/// - リスト作成: createShoppingList → (shoppingListCreated | shoppingListCreateFailed)
/// - リスト削除: deleteShoppingList → (shoppingListDeleted | shoppingListDeleteFailed)
/// - アイテムチェック: updateItemChecked → (itemCheckedUpdated | itemCheckUpdateFailed)
public enum ShoppingListAction: Sendable {
    // MARK: - Load Lists

    /// 買い物リスト一覧を読み込む（副作用: PersistenceService呼び出し → shoppingListsLoaded or shoppingListsLoadFailed）
    case loadShoppingLists

    /// 買い物リスト一覧読み込み成功
    case shoppingListsLoaded([ShoppingListDTO])

    /// 買い物リスト一覧読み込み失敗
    case shoppingListsLoadFailed(String)

    // MARK: - Create List

    /// 買い物リストを作成（副作用: PersistenceService呼び出し → shoppingListCreated or shoppingListCreateFailed）
    case createShoppingList(name: String, recipeIDs: [UUID])

    /// 買い物リスト作成成功
    case shoppingListCreated(ShoppingListDTO)

    /// 買い物リスト作成失敗
    case shoppingListCreateFailed(String)

    // MARK: - Delete List

    /// 買い物リストを削除（副作用: PersistenceService呼び出し → shoppingListDeleted or shoppingListDeleteFailed）
    case deleteShoppingList(id: UUID)

    /// 買い物リスト削除成功
    case shoppingListDeleted(id: UUID)

    /// 買い物リスト削除失敗
    case shoppingListDeleteFailed(String)

    // MARK: - Select List

    /// 買い物リストを選択
    case selectShoppingList(ShoppingListDTO)

    /// 選択をクリア
    case clearCurrentShoppingList

    // MARK: - Item Check

    /// アイテムのチェック状態を更新（副作用: PersistenceService呼び出し → itemCheckedUpdated or itemCheckUpdateFailed）
    case updateItemChecked(itemID: UUID, isChecked: Bool)

    /// アイテムチェック更新成功
    case itemCheckedUpdated(itemID: UUID, isChecked: Bool)

    /// アイテムチェック更新失敗
    case itemCheckUpdateFailed(String)

    // MARK: - Clear

    /// エラーをクリア
    case clearError
}
