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

    // Category management state
    @State private var showingAddCategory: Bool = false
    @State private var newCategoryName: String = ""
    @State private var showingRenameCategory: Bool = false
    @State private var renameCategoryName: String = ""
    @State private var categoryToManage: RecipeCategory?
    @State private var showingCategoryActions: Bool = false
    @State private var showingDeleteCategoryConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            RecipeHomeView(
                recipes: store.state.recipe.filteredRecipes,
                categories: store.state.recipe.categories,
                selectedCategoryID: store.state.recipe.selectedCategoryFilter,
                isLoading: store.state.recipe.isLoadingSavedRecipes,
                onRecipeTapped: { recipe in
                    store.send(.recipe(.selectSavedRecipe(recipe)))
                    showingRecipe = true
                },
                onAddTapped: {
                    showingAddRecipe = true
                },
                onDeleteConfirmed: { id in
                    store.send(.recipe(.deleteRecipe(id: id)))
                },
                onCategoryTapped: { categoryID in
                    store.send(.recipe(.selectCategoryFilter(categoryID)))
                },
                onAddCategoryTapped: {
                    newCategoryName = ""
                    showingAddCategory = true
                },
                onCategoryLongPressed: { category in
                    categoryToManage = category
                    showingCategoryActions = true
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
                    isLoading: store.state.recipe.isLoadingRecipe,
                    onExtractTapped: {
                        extractRecipe()
                    },
                    onCloseTapped: {
                        showingAddRecipe = false
                    }
                )
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
            // カテゴリ作成アラート
            .alert(
                String(localized: .categoryAddTitle),
                isPresented: $showingAddCategory
            ) {
                TextField(String(localized: .categoryAddPlaceholder), text: $newCategoryName)
                Button(String(localized: .commonCreate)) {
                    let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !name.isEmpty {
                        store.send(.recipe(.createCategory(name: name)))
                    }
                }
                Button(String(localized: .commonCancel), role: .cancel) {}
            }
            // カテゴリ操作メニュー（長押し）
            .confirmationDialog(
                categoryToManage?.name ?? "",
                isPresented: $showingCategoryActions,
                titleVisibility: .visible
            ) {
                Button(String(localized: .categoryRename)) {
                    renameCategoryName = categoryToManage?.name ?? ""
                    showingRenameCategory = true
                }
                Button(String(localized: .commonDelete), role: .destructive) {
                    showingDeleteCategoryConfirmation = true
                }
                Button(String(localized: .commonCancel), role: .cancel) {}
            }
            // カテゴリ名変更アラート
            .alert(
                String(localized: .categoryRenameTitle),
                isPresented: $showingRenameCategory
            ) {
                TextField(String(localized: .categoryAddPlaceholder), text: $renameCategoryName)
                Button(String(localized: .commonOk)) {
                    let name = renameCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !name.isEmpty, let category = categoryToManage {
                        store.send(.recipe(.renameCategory(id: category.id, newName: name)))
                    }
                }
                Button(String(localized: .commonCancel), role: .cancel) {}
            }
            // カテゴリ削除確認
            .alert(
                String(localized: .categoryDeleteTitle),
                isPresented: $showingDeleteCategoryConfirmation
            ) {
                Button(String(localized: .commonDelete), role: .destructive) {
                    if let category = categoryToManage {
                        store.send(.recipe(.deleteCategory(id: category.id)))
                    }
                }
                Button(String(localized: .commonCancel), role: .cancel) {}
            } message: {
                Text(.categoryDeleteMessage)
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
