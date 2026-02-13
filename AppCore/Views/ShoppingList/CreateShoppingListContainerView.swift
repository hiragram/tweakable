import SwiftUI

// MARK: - CreateShoppingListContainerView

/// 買い物リスト作成画面のContainerView
struct CreateShoppingListContainerView: View {
    let store: AppStore
    let onCreated: (ShoppingListDTO) -> Void
    let onCancelled: () -> Void

    @State private var searchText: String = ""

    var body: some View {
        let recipeState = store.state.recipe
        let slState = store.state.shoppingList
        let query = slState.recipeSearchQuery
        let isSearchActive = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let allSearchResults = RecipeSearchHelper.searchResults(
            recipes: recipeState.savedRecipes,
            query: query
        )
        let filteredResults = RecipeSearchHelper.filteredResults(
            results: allSearchResults,
            categoryID: slState.selectedRecipeSearchCategoryFilter,
            categoryRecipeMap: recipeState.categoryRecipeMap
        )

        CreateShoppingListView(
            savedRecipes: recipeState.savedRecipes,
            searchResults: filteredResults,
            categories: recipeState.categories,
            selectedCategoryID: slState.selectedRecipeSearchCategoryFilter,
            categoryCounts: RecipeSearchHelper.categoryCounts(
                results: allSearchResults,
                categoryRecipeMap: recipeState.categoryRecipeMap
            ),
            totalSearchResultCount: allSearchResults.count,
            isSearchActive: isSearchActive,
            isCreating: slState.isCreatingList,
            onCategoryTapped: { id in
                store.send(.shoppingList(.selectRecipeSearchCategoryFilter(id)))
            },
            onCreateTapped: { name, recipeIDs in
                store.send(.shoppingList(.createShoppingList(name: name, recipeIDs: recipeIDs)))
            },
            onCancelTapped: onCancelled
        )
        .searchable(text: $searchText, prompt: String(localized: .searchRecipesPlaceholder))
        .onChange(of: searchText) { _, newValue in
            store.send(.shoppingList(.updateRecipeSearchQuery(newValue)))
        }
        .onChange(of: store.state.shoppingList.shoppingLists) { oldValue, newValue in
            if let newList = newValue.last, !oldValue.contains(where: { $0.id == newList.id }) {
                onCreated(newList)
            }
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use CreateShoppingListView preview instead
