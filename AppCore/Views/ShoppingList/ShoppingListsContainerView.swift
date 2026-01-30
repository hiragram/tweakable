import SwiftUI

// MARK: - ShoppingListsContainerView

/// 買い物リスト一覧画面のContainerView
struct ShoppingListsContainerView: View {
    let store: AppStore
    let onListSelected: (ShoppingListDTO) -> Void

    @State private var showingCreateSheet: Bool = false

    var body: some View {
        ShoppingListsView(
            shoppingLists: store.state.shoppingList.shoppingLists,
            isLoading: store.state.shoppingList.isLoadingLists,
            onListTapped: { list in
                store.send(.shoppingList(.selectShoppingList(list)))
                onListSelected(list)
            },
            onDeleteTapped: { id in
                store.send(.shoppingList(.deleteShoppingList(id: id)))
            },
            onCreateTapped: {
                showingCreateSheet = true
            }
        )
        .onAppear {
            store.send(.shoppingList(.loadShoppingLists))
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateShoppingListContainerView(
                store: store,
                onCreated: { _ in
                    showingCreateSheet = false
                },
                onCancelled: {
                    showingCreateSheet = false
                }
            )
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use ShoppingListsView preview instead
