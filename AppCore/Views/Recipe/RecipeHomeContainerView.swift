import SwiftUI

// MARK: - RecipeHomeContainerView

/// レシピホーム画面のContainer（Storeと接続）
struct RecipeHomeContainerView: View {
    let store: AppStore

    @State private var urlText: String = ""
    @State private var showingAddRecipe: Bool = false
    @State private var showingRecipe: Bool = false
    @State private var showingShoppingLists: Bool = false
    @State private var showingShoppingListDetail: Bool = false
    @State private var isLoadingRecipe: Bool = false

    var body: some View {
        NavigationStack {
            RecipeHomeView(
                recipes: store.state.recipe.savedRecipes,
                isLoading: store.state.recipe.isLoadingSavedRecipes,
                onRecipeTapped: { recipe in
                    store.send(.recipe(.selectSavedRecipe(recipe)))
                    showingRecipe = true
                },
                onAddTapped: {
                    showingAddRecipe = true
                }
            )
            .navigationTitle(String(localized: .myRecipesTitle))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button(action: { showingShoppingLists = true }) {
                            Image(systemName: "cart")
                        }
                        .accessibilityIdentifier("recipeHome_button_shoppingLists")

                        Button(action: { showingAddRecipe = true }) {
                            Image(systemName: "plus")
                        }
                        .accessibilityIdentifier("recipeHome_button_add")
                    }
                }
            }
            .navigationDestination(isPresented: $showingRecipe) {
                RecipeContainerView(store: store)
            }
            .navigationDestination(isPresented: $showingShoppingLists) {
                ShoppingListsContainerView(
                    store: store,
                    onListSelected: { _ in
                        showingShoppingListDetail = true
                    }
                )
                .navigationDestination(isPresented: $showingShoppingListDetail) {
                    ShoppingListDetailContainerView(store: store)
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(
                    urlText: $urlText,
                    isLoading: $isLoadingRecipe,
                    onExtractTapped: {
                        extractRecipe()
                    },
                    onCloseTapped: {
                        showingAddRecipe = false
                    }
                )
            }
            .onChange(of: store.state.recipe.isLoadingRecipe) { _, newValue in
                isLoadingRecipe = newValue
            }
            .alert(
                String(localized: .recipeErrorTitle),
                isPresented: .init(
                    get: { store.state.recipe.errorMessage != nil && !store.state.recipe.isLoadingRecipe },
                    set: { if !$0 { store.send(.recipe(.clearError)) } }
                )
            ) {
                Button(String(localized: .commonOk), role: .cancel) {
                    store.send(.recipe(.clearError))
                }
            } message: {
                if let errorMessage = store.state.recipe.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: store.state.recipe.currentRecipe) { oldValue, newValue in
                // レシピが読み込まれたら詳細画面へ遷移し、シートを閉じる
                if oldValue == nil && newValue != nil {
                    showingAddRecipe = false
                    urlText = ""
                    showingRecipe = true
                }
            }
            .onChange(of: showingRecipe) { oldValue, newValue in
                // 詳細画面から戻ったらレシピをクリア
                if oldValue == true && newValue == false {
                    store.send(.recipe(.clearRecipe))
                }
            }
            // 保存済みレシピと買い物リストのロードはRootView経由でbootアクションで行う
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
