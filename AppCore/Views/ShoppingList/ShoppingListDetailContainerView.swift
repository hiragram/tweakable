import SwiftUI

// MARK: - ShoppingListDetailContainerView

/// 買い物リスト詳細画面のContainerView
struct ShoppingListDetailContainerView: View {
    let store: AppStore

    @State private var showingRecipeFromList: Bool = false

    /// 現在の買い物リストに含まれるレシピを解決
    private var recipesInList: [Recipe] {
        guard let shoppingList = store.state.shoppingList.currentShoppingList else { return [] }
        let savedRecipes = store.state.recipe.savedRecipes
        return shoppingList.recipeIDs.compactMap { recipeID in
            savedRecipes.first { $0.id == recipeID }
        }
    }

    var body: some View {
        Group {
            if let shoppingList = store.state.shoppingList.currentShoppingList {
                ShoppingListDetailView(
                    shoppingList: shoppingList,
                    recipes: recipesInList,
                    isUpdatingItem: store.state.shoppingList.isUpdatingItem,
                    onItemCheckedChanged: { itemID, isChecked in
                        store.send(.shoppingList(.updateItemChecked(itemID: itemID, isChecked: isChecked)))
                    },
                    onRecipeTapped: { recipe in
                        store.send(.recipe(.selectSavedRecipe(recipe)))
                        showingRecipeFromList = true
                    }
                )
            } else {
                // Should not happen in normal flow
                Text("shopping_list_detail_not_found", bundle: .app)
            }
        }
        .navigationDestination(isPresented: $showingRecipeFromList) {
            RecipeContainerView(store: store)
        }
        .onChange(of: showingRecipeFromList) { oldValue, newValue in
            if oldValue == true && newValue == false {
                store.send(.recipe(.clearRecipe))
            }
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use ShoppingListDetailView preview instead
