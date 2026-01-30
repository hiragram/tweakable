import SwiftUI

// MARK: - RecipeHomeContainerView

/// レシピホーム画面のContainer（Storeと接続）
struct RecipeHomeContainerView: View {
    let store: AppStore

    @State private var urlText: String = ""
    @State private var showingRecipe: Bool = false
    @State private var showingSavedRecipes: Bool = false
    @State private var showingShoppingLists: Bool = false
    @State private var showingShoppingListDetail: Bool = false

    var body: some View {
        NavigationStack {
            RecipeHomeView(
                urlText: $urlText,
                isLoading: store.state.recipe.isLoadingRecipe,
                savedRecipesCount: store.state.recipe.savedRecipes.count,
                shoppingListsCount: store.state.shoppingList.shoppingLists.count,
                onExtractTapped: {
                    extractRecipe()
                },
                onSavedRecipesTapped: {
                    showingSavedRecipes = true
                },
                onShoppingListsTapped: {
                    showingShoppingLists = true
                }
            )
            .navigationTitle(String(localized: "recipe_home_navigation_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showingRecipe) {
                RecipeContainerView(store: store)
            }
            .navigationDestination(isPresented: $showingSavedRecipes) {
                SavedRecipesContainerView(
                    store: store,
                    onRecipeSelected: { recipe in
                        showingSavedRecipes = false
                        showingRecipe = true
                    }
                )
            }
            .navigationDestination(isPresented: $showingShoppingLists) {
                ShoppingListsContainerView(
                    store: store,
                    onListSelected: { list in
                        showingShoppingListDetail = true
                    }
                )
                .navigationDestination(isPresented: $showingShoppingListDetail) {
                    ShoppingListDetailContainerView(store: store)
                }
            }
            .alert(
                String(localized: "recipe_error_title", bundle: .app),
                isPresented: .init(
                    get: { store.state.recipe.errorMessage != nil && !store.state.recipe.isLoadingRecipe },
                    set: { if !$0 { store.send(.recipe(.clearError)) } }
                )
            ) {
                Button(String(localized: "common_ok", bundle: .app), role: .cancel) {
                    store.send(.recipe(.clearError))
                }
            } message: {
                if let errorMessage = store.state.recipe.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: store.state.recipe.currentRecipe) { oldValue, newValue in
                // レシピが読み込まれたら詳細画面へ遷移
                if oldValue == nil && newValue != nil {
                    showingRecipe = true
                }
            }
            .onChange(of: showingRecipe) { oldValue, newValue in
                // 詳細画面から戻ったらレシピをクリア
                if oldValue == true && newValue == false {
                    store.send(.recipe(.clearRecipe))
                }
            }
            .onAppear {
                // アプリ起動時に保存済みレシピと買い物リストを読み込む
                store.send(.recipe(.loadSavedRecipes))
                store.send(.shoppingList(.loadShoppingLists))
            }
        }
    }

    private func extractRecipe() {
        let finalURL: URL?

        if let url = URL(string: urlText), url.scheme != nil {
            finalURL = url
        } else {
            // httpsを補完して再試行
            finalURL = URL(string: "https://\(urlText)")
        }

        guard let url = finalURL, url.scheme == "https" else {
            // HTTPSスキーム以外は拒否
            return
        }

        store.send(.recipe(.loadRecipe(url: url)))
    }
}

// MARK: - Preview

#Preview {
    RecipeHomeContainerView(store: AppStore())
}
