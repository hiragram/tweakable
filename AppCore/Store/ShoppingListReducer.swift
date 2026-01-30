import Foundation

/// 買い物リスト機能のReducer（純粋関数）
public enum ShoppingListReducer {
    /// 状態を更新する
    public static func reduce(state: inout ShoppingListState, action: ShoppingListAction) {
        switch action {
        // MARK: - Load Lists

        case .loadShoppingLists:
            state.isLoadingLists = true

        case .shoppingListsLoaded(let lists):
            state.isLoadingLists = false
            state.shoppingLists = lists

        case .shoppingListsLoadFailed(let message):
            state.isLoadingLists = false
            state.errorMessage = message

        // MARK: - Create List

        case .createShoppingList:
            state.isCreatingList = true

        case .shoppingListCreated(let list):
            state.isCreatingList = false
            state.shoppingLists.append(list)

        case .shoppingListCreateFailed(let message):
            state.isCreatingList = false
            state.errorMessage = message

        // MARK: - Delete List

        case .deleteShoppingList:
            state.isDeletingList = true

        case .shoppingListDeleted(let id):
            state.isDeletingList = false
            state.shoppingLists.removeAll { $0.id == id }

        case .shoppingListDeleteFailed(let message):
            state.isDeletingList = false
            state.errorMessage = message

        // MARK: - Select List

        case .selectShoppingList(let list):
            state.currentShoppingList = list

        case .clearCurrentShoppingList:
            state.currentShoppingList = nil

        // MARK: - Item Check

        case .updateItemChecked:
            state.isUpdatingItem = true

        case .itemCheckedUpdated(let itemID, let isChecked):
            state.isUpdatingItem = false
            // currentShoppingList内のアイテムを更新
            if var currentList = state.currentShoppingList {
                currentList.items = currentList.items.map { item in
                    if item.id == itemID {
                        return ShoppingListItemDTO(
                            id: item.id,
                            name: item.name,
                            totalAmount: item.totalAmount,
                            category: item.category,
                            isChecked: isChecked,
                            breakdowns: item.breakdowns
                        )
                    }
                    return item
                }
                state.currentShoppingList = currentList
            }

        case .itemCheckUpdateFailed(let message):
            state.isUpdatingItem = false
            state.errorMessage = message

        // MARK: - Clear

        case .clearError:
            state.errorMessage = nil
        }
    }
}
