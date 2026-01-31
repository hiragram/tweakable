import Foundation
import os
import SwiftData
import SwiftUI

private let actionLogger = Logger(subsystem: "com.tweakable.app", category: "Actions")

/// アプリ全体のStore（状態保持 + Action dispatch）
@MainActor
@Observable
public final class AppStore {
    // MARK: - State

    public private(set) var state = AppState()

    // MARK: - Dependencies

    private let recipeExtractionService: any RecipeExtractionServiceProtocol
    private let recipePersistenceService: any RecipePersistenceServiceProtocol

    // MARK: - Initialization

    public init(
        recipeExtractionService: (any RecipeExtractionServiceProtocol)? = nil,
        recipePersistenceService: (any RecipePersistenceServiceProtocol)? = nil
    ) {
        // RecipeExtractionService のデフォルト構成
        if let service = recipeExtractionService {
            self.recipeExtractionService = service
        } else {
            let configService = ConfigurationService()
            let htmlFetcher = HTMLFetcher()
            let openAIClient = OpenAIClient(configurationService: configService)
            self.recipeExtractionService = RecipeExtractionService(
                htmlFetcher: htmlFetcher,
                openAIClient: openAIClient,
                configurationService: configService
            )
        }

        // RecipePersistenceService のデフォルト構成
        if let service = recipePersistenceService {
            self.recipePersistenceService = service
        } else {
            do {
                let container = try ModelContainerProvider.makeContainer()
                self.recipePersistenceService = RecipePersistenceService(modelContainer: container)
            } catch {
                // グレースフルデグラデーション: 永続化なしで動作
                print("Warning: ModelContainer initialization failed, running without persistence: \(error)")
                self.recipePersistenceService = NoOpRecipePersistenceService()
            }
        }
    }

    // MARK: - Public Methods

    /// アクションを送信
    public func send(_ action: AppAction) {
        actionLogger.debug("Action: \(String(describing: action))")

        // 1. Reducerで状態更新
        AppReducer.reduce(state: &state, action: action)

        // 2. 副作用の実行
        Task {
            await handleSideEffects(action)
        }
    }

    // MARK: - Side Effects

    private func handleSideEffects(_ action: AppAction) async {
        switch action {
        case .boot:
            // 起動時の副作用なし
            break

        case .recipe(let recipeAction):
            await handleRecipeSideEffects(recipeAction)

        case .shoppingList(let shoppingListAction):
            await handleShoppingListSideEffects(shoppingListAction)
        }
    }

    // MARK: - Recipe Side Effects

    private func handleRecipeSideEffects(_ action: RecipeAction) async {
        switch action {
        case .loadRecipe(let url):
            do {
                let recipe = try await recipeExtractionService.extractRecipe(from: url)
                send(.recipe(.recipeLoaded(recipe)))
            } catch {
                let message = buildRecipeErrorMessage(error, context: .load)
                print("RecipeExtractionError: \(message)")
                send(.recipe(.recipeLoadFailed(message)))
            }

        case .requestSubstitution(let prompt):
            guard let recipe = state.recipe.currentRecipe,
                  let target = state.recipe.substitutionTarget else {
                send(.recipe(.substitutionFailed(String(localized: .substitutionErrorNoTarget))))
                return
            }

            do {
                let updatedRecipe = try await recipeExtractionService.substituteRecipe(
                    recipe: recipe,
                    target: target,
                    prompt: prompt
                )
                send(.recipe(.substitutionPreviewReady(updatedRecipe)))
            } catch {
                let message = buildRecipeErrorMessage(error, context: .substitution)
                send(.recipe(.substitutionFailed(message)))
            }

        case .requestAdditionalSubstitution(let prompt):
            // previewRecipeをベースにLLM再呼び出し
            guard let previewRecipe = state.recipe.previewRecipe,
                  let target = state.recipe.substitutionTarget else {
                send(.recipe(.substitutionFailed(String(localized: .substitutionErrorNoTarget))))
                return
            }

            do {
                let updatedRecipe = try await recipeExtractionService.substituteRecipe(
                    recipe: previewRecipe,
                    target: target,
                    prompt: prompt
                )
                send(.recipe(.substitutionPreviewReady(updatedRecipe)))
            } catch {
                let message = buildRecipeErrorMessage(error, context: .substitution)
                send(.recipe(.substitutionFailed(message)))
            }

        case .saveRecipe:
            guard let recipe = state.recipe.currentRecipe else { return }
            do {
                try await recipePersistenceService.saveRecipe(recipe)
                send(.recipe(.recipeSaved(recipe)))
            } catch {
                send(.recipe(.recipeSaveFailed(error.localizedDescription)))
            }

        case .loadSavedRecipes:
            do {
                let recipes = try await recipePersistenceService.loadAllRecipes()
                send(.recipe(.savedRecipesLoaded(recipes)))
            } catch {
                send(.recipe(.savedRecipesLoadFailed(error.localizedDescription)))
            }

        case .deleteRecipe(let id):
            do {
                try await recipePersistenceService.deleteRecipe(id: id)
                send(.recipe(.recipeDeleted(id: id)))
            } catch {
                send(.recipe(.recipeDeleteFailed(error.localizedDescription)))
            }

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    // MARK: - Recipe Error Handling

    /// エラーメッセージを構築するコンテキスト
    private enum RecipeErrorContext {
        case load
        case substitution
    }

    /// RecipeExtractionErrorからローカライズされたエラーメッセージを構築
    private func buildRecipeErrorMessage(_ error: Error, context: RecipeErrorContext) -> String {
        if let recipeError = error as? RecipeExtractionError {
            switch recipeError {
            case .htmlFetchFailed(let detail):
                return context == .load
                    ? String(localized: .recipeErrorHtmlFetchFailed(detail))
                    : String(localized: .substitutionErrorFailed) + ": \(detail)"
            case .apiKeyNotConfigured:
                return String(localized: .recipeErrorApiKeyNotConfigured)
            case .extractionFailed(let detail):
                return context == .load
                    ? String(localized: .recipeErrorExtractionFailed(detail))
                    : String(localized: .substitutionErrorFailed) + ": \(detail)"
            }
        } else {
            let baseMessage = context == .load
                ? String(localized: .recipeErrorUnexpected)
                : String(localized: .substitutionErrorUnexpected)
            return baseMessage + ": \(error.localizedDescription)"
        }
    }

    // MARK: - ShoppingList Side Effects

    private func handleShoppingListSideEffects(_ action: ShoppingListAction) async {
        switch action {
        case .loadShoppingLists:
            do {
                let lists = try await recipePersistenceService.loadAllShoppingLists()
                send(.shoppingList(.shoppingListsLoaded(lists)))
            } catch {
                send(.shoppingList(.shoppingListsLoadFailed(error.localizedDescription)))
            }

        case .createShoppingList(let name, let recipeIDs):
            do {
                let list = try await recipePersistenceService.createShoppingList(name: name, recipeIDs: recipeIDs)
                send(.shoppingList(.shoppingListCreated(list)))
            } catch {
                send(.shoppingList(.shoppingListCreateFailed(error.localizedDescription)))
            }

        case .deleteShoppingList(let id):
            do {
                try await recipePersistenceService.deleteShoppingList(id: id)
                send(.shoppingList(.shoppingListDeleted(id: id)))
            } catch {
                send(.shoppingList(.shoppingListDeleteFailed(error.localizedDescription)))
            }

        case .updateItemChecked(let itemID, let isChecked):
            do {
                try await recipePersistenceService.updateShoppingItemChecked(itemID: itemID, isChecked: isChecked)
                send(.shoppingList(.itemCheckedUpdated(itemID: itemID, isChecked: isChecked)))
            } catch {
                send(.shoppingList(.itemCheckUpdateFailed(error.localizedDescription)))
            }

        default:
            // その他のアクションは副作用なし
            break
        }
    }
}
