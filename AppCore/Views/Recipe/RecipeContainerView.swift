import SwiftUI

// MARK: - RecipeContainerView

struct RecipeContainerView: View {
    let store: AppStore

    /// State for showing substitution sheet
    @State private var showsSubstitutionSheet = false

    /// Whether the user is a premium subscriber
    /// TODO: Implement RevenueCat integration for premium subscription check (MVP requirement)
    private var isPremiumUser: Bool {
        // SECURITY: This MUST be implemented before production release
        #if DEBUG
        return true  // Development only - REMOVE BEFORE SHIPPING
        #else
        // Production builds require RevenueCat integration
        // This will cause a compile error until properly implemented
        #error("RevenueCat integration required before production build")
        #endif
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
                // TODO: Navigate to shopping list screen (MVP requirement, separate task)
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
                        // TODO: Show RevenueCat paywall for premium subscription (MVP requirement, separate task)
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

// Preview requires AppStore instance, so use RecipeView preview instead
