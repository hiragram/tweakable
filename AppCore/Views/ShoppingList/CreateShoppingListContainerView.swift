import SwiftUI

// MARK: - CreateShoppingListContainerView

/// 買い物リスト作成画面のContainerView
struct CreateShoppingListContainerView: View {
    let store: AppStore
    let onCreated: (ShoppingListDTO) -> Void
    let onCancelled: () -> Void

    var body: some View {
        CreateShoppingListView(
            savedRecipes: store.state.recipe.savedRecipes,
            isCreating: store.state.shoppingList.isCreatingList,
            onCreateTapped: { name, recipeIDs in
                store.send(.shoppingList(.createShoppingList(name: name, recipeIDs: recipeIDs)))
            },
            onCancelTapped: onCancelled
        )
        .onChange(of: store.state.shoppingList.shoppingLists) { oldValue, newValue in
            // 新しいリストが追加されたら、それを通知
            if let newList = newValue.last, !oldValue.contains(where: { $0.id == newList.id }) {
                onCreated(newList)
            }
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use CreateShoppingListView preview instead
