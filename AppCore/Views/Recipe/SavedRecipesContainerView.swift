import SwiftUI

// MARK: - SavedRecipesContainerView

/// 保存済みレシピ一覧画面のContainerView
struct SavedRecipesContainerView: View {
    let store: AppStore
    let onRecipeSelected: (Recipe) -> Void

    var body: some View {
        SavedRecipesListView(
            recipes: store.state.recipe.savedRecipes,
            isLoading: store.state.recipe.isLoadingSavedRecipes,
            onRecipeTapped: { recipe in
                store.send(.recipe(.selectSavedRecipe(recipe)))
                onRecipeSelected(recipe)
            },
            onDeleteTapped: { id in
                store.send(.recipe(.deleteRecipe(id: id)))
            }
        )
        .onAppear {
            store.send(.recipe(.loadSavedRecipes))
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use SavedRecipesListView preview instead
