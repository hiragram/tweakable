import SwiftUI

// MARK: - RecipeContainerView

struct RecipeContainerView: View {
    let store: AppStore

    /// State for showing substitution sheet
    @State private var showsSubstitutionSheet = false

    /// State for showing category assignment sheet
    @State private var showsCategoryAssignment = false
    @State private var showingAddCategoryFromAssignment = false
    @State private var newCategoryNameFromAssignment = ""

    /// Whether the user is a premium subscriber (from RevenueCat)
    private var isPremiumUser: Bool {
        store.state.subscription.isPremium
    }

    /// 現在のレシピに割り当てられているカテゴリIDのSet
    private var assignedCategoryIDs: Set<UUID> {
        guard let recipeID = store.state.recipe.currentRecipe?.id else { return [] }
        var result: Set<UUID> = []
        for (categoryID, recipeIDs) in store.state.recipe.categoryRecipeMap {
            if recipeIDs.contains(recipeID) {
                result.insert(categoryID)
            }
        }
        return result
    }

    var body: some View {
        RecipeView(
            recipe: store.state.recipe.currentRecipe,
            isLoading: store.state.recipe.isLoadingRecipe,
            errorMessage: store.state.recipe.errorMessage,
            onIngredientTapped: { ingredient in
                store.send(.recipe(.openSubstitutionSheet(ingredient: ingredient)))
                showsSubstitutionSheet = true
            },
            onStepTapped: { step in
                store.send(.recipe(.openSubstitutionSheetForStep(step: step)))
                showsSubstitutionSheet = true
            },
            onRetryTapped: {
                if let url = store.state.recipe.currentRecipe?.sourceURL {
                    store.send(.recipe(.loadRecipe(url: url)))
                }
            }
        )
        .sheet(isPresented: $showsSubstitutionSheet) {
            if let target = store.state.recipe.substitutionTarget {
                SubstitutionSheetView(
                    store: store,
                    target: target,
                    isProcessing: store.state.recipe.isProcessingSubstitution,
                    isPremiumUser: isPremiumUser,
                    errorMessage: store.state.recipe.errorMessage,
                    sheetMode: store.state.recipe.substitutionSheetMode,
                    previewRecipe: store.state.recipe.previewRecipe,
                    originalRecipe: store.state.recipe.originalRecipeSnapshot,
                    onSubmit: { prompt in
                        store.send(.recipe(.requestSubstitution(prompt: prompt)))
                    },
                    onDismiss: {
                        store.send(.recipe(.closeSubstitutionSheet))
                        showsSubstitutionSheet = false
                    },
                    onApprove: {
                        store.send(.recipe(.approveSubstitution))
                    },
                    onReject: {
                        store.send(.recipe(.rejectSubstitution))
                    },
                    onRequestMore: { prompt in
                        store.send(.recipe(.requestAdditionalSubstitution(prompt: prompt)))
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .onChange(of: store.state.recipe.substitutionTarget) { oldValue, newValue in
            // When substitution is completed, close the sheet
            if oldValue != nil && newValue == nil {
                showsSubstitutionSheet = false
            }
        }
        .toolbar {
            if store.state.recipe.currentRecipe != nil && !store.state.recipe.categories.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showsCategoryAssignment = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .accessibilityIdentifier("recipe_button_assignCategory")
                }
            }
        }
        .sheet(isPresented: $showsCategoryAssignment) {
            NavigationStack {
                CategoryAssignmentView(
                    categories: store.state.recipe.categories,
                    assignedCategoryIDs: assignedCategoryIDs,
                    onToggleCategory: { categoryID, shouldAdd in
                        guard let recipeID = store.state.recipe.currentRecipe?.id else { return }
                        if shouldAdd {
                            store.send(.recipe(.addRecipeToCategory(recipeID: recipeID, categoryID: categoryID)))
                        } else {
                            store.send(.recipe(.removeRecipeFromCategory(recipeID: recipeID, categoryID: categoryID)))
                        }
                    },
                    onAddCategoryTapped: {
                        newCategoryNameFromAssignment = ""
                        showingAddCategoryFromAssignment = true
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: .commonOk)) {
                            showsCategoryAssignment = false
                        }
                        .accessibilityIdentifier("categoryAssignment_button_done")
                    }
                }
                .alert(
                    String(localized: .categoryAddTitle),
                    isPresented: $showingAddCategoryFromAssignment
                ) {
                    TextField(String(localized: .categoryAddPlaceholder), text: $newCategoryNameFromAssignment)
                    Button(String(localized: .commonCreate)) {
                        let name = newCategoryNameFromAssignment.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty {
                            store.send(.recipe(.createCategory(name: name)))
                        }
                    }
                    Button(String(localized: .commonCancel), role: .cancel) {}
                }
            }
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Preview

// Preview requires AppStore instance, so use RecipeView preview instead
