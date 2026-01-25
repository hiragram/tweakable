import SwiftUI

// MARK: - RecipeContainerView

struct RecipeContainerView: View {
    let store: AppStore

    /// State for showing substitution sheet
    @State private var showsSubstitutionSheet = false

    /// Whether the user is a premium subscriber
    /// TODO: Implement RevenueCat integration
    private var isPremiumUser: Bool {
        // For now, return true for development
        true
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
            },
            onShoppingListTapped: {
                // TODO: Navigate to shopping list
            }
        )
        .sheet(isPresented: $showsSubstitutionSheet) {
            if let target = store.state.recipe.substitutionTarget {
                SubstitutionSheetView(
                    target: target,
                    isProcessing: store.state.recipe.isProcessingSubstitution,
                    isPremiumUser: isPremiumUser,
                    errorMessage: store.state.recipe.errorMessage,
                    onSubmit: { prompt in
                        store.send(.recipe(.requestSubstitution(prompt: prompt)))
                    },
                    onUpgradeTapped: {
                        // TODO: Show paywall
                    },
                    onDismiss: {
                        store.send(.recipe(.closeSubstitutionSheet))
                        showsSubstitutionSheet = false
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
    }
}

// MARK: - Preview

// Preview requires mock dependencies, so use RecipeView preview instead
