import SwiftUI

// MARK: - ShoppingListDetailContainerView

/// 買い物リスト詳細画面のContainerView
struct ShoppingListDetailContainerView: View {
    let store: AppStore

    var body: some View {
        Group {
            if let shoppingList = store.state.shoppingList.currentShoppingList {
                ShoppingListDetailView(
                    shoppingList: shoppingList,
                    isUpdatingItem: store.state.shoppingList.isUpdatingItem,
                    onItemCheckedChanged: { itemID, isChecked in
                        store.send(.shoppingList(.updateItemChecked(itemID: itemID, isChecked: isChecked)))
                    }
                )
            } else {
                // Should not happen in normal flow
                Text("shopping_list_detail_not_found", bundle: .app)
            }
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use ShoppingListDetailView preview instead
