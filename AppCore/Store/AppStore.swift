import Foundation
import os
import RevenueCat
import SwiftData
import SwiftUI
import TipKit

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
    private let revenueCatService: any RevenueCatServiceProtocol
    private let seedDataService: SeedDataService

    // MARK: - Initialization

    public init(
        recipeExtractionService: (any RecipeExtractionServiceProtocol)? = nil,
        recipePersistenceService: (any RecipePersistenceServiceProtocol)? = nil,
        revenueCatService: any RevenueCatServiceProtocol = RevenueCatService()
    ) {
        self.revenueCatService = revenueCatService

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

        self.seedDataService = SeedDataService(persistenceService: self.recipePersistenceService)
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
            await handleBoot()

        case .recipe(let recipeAction):
            await handleRecipeSideEffects(recipeAction)

        case .shoppingList(let shoppingListAction):
            await handleShoppingListSideEffects(shoppingListAction)

        case .subscription(let subscriptionAction):
            await handleSubscriptionSideEffects(subscriptionAction)

        #if DEBUG
        case .debug(let debugAction):
            await handleDebugSideEffects(debugAction)
        #endif
        }
    }

    /// アプリ起動時の処理
    private func handleBoot() async {
        // サブスクリプション状態と買い物リストを先に読み込む（シードデータ投入を待たない）
        send(.subscription(.loadSubscriptionStatus))
        send(.shoppingList(.loadShoppingLists))

        // シードデータ投入（初回のみ）完了後にレシピ・カテゴリを読み込む
        await seedDataService.seedIfNeeded()
        send(.recipe(.loadSavedRecipes))
        send(.recipe(.loadCategories))
    }

    // MARK: - Recipe Side Effects

    /// プレミアム機能の利用可否をチェックし、非プレミアムの場合はエラーを送信
    /// - Returns: プレミアムユーザーの場合は `true`、非プレミアムの場合は `false`
    private func requiresPremium() -> Bool {
        guard state.subscription.isPremium else {
            send(.recipe(.substitutionFailed(String(localized: .substitutionErrorPremiumRequired))))
            return false
        }
        return true
    }

    private func handleRecipeSideEffects(_ action: RecipeAction) async {
        switch action {
        case .loadRecipe(let url):
            do {
                let recipe = try await recipeExtractionService.extractRecipe(from: url)
                send(.recipe(.recipeLoaded(recipe)))
                // レシピ解析完了時に自動保存（ユーザーが明示的に保存操作をしなくても、保存済みレシピ一覧で確認できるようにする）
                send(.recipe(.saveRecipe))
                TipEvents.recipeAdded.sendDonation()
            } catch {
                let message = buildRecipeErrorMessage(error, context: .load)
                print("RecipeExtractionError: \(message)")
                send(.recipe(.recipeLoadFailed(message)))
            }

        case .requestSubstitution(let prompt):
            guard requiresPremium() else { return }
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
                // 置き換え対象によってイベントを発火
                switch target {
                case .ingredient:
                    TipEvents.ingredientSubstituted.sendDonation()
                case .step:
                    TipEvents.stepSubstituted.sendDonation()
                }
            } catch {
                let message = buildRecipeErrorMessage(error, context: .substitution)
                send(.recipe(.substitutionFailed(message)))
            }

        case .requestAdditionalSubstitution(let prompt):
            guard requiresPremium() else { return }
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
                // 置き換え対象によってイベントを発火
                switch target {
                case .ingredient:
                    TipEvents.ingredientSubstituted.sendDonation()
                case .step:
                    TipEvents.stepSubstituted.sendDonation()
                }
            } catch {
                let message = buildRecipeErrorMessage(error, context: .substitution)
                send(.recipe(.substitutionFailed(message)))
            }

        case .saveRecipe:
            guard let recipe = state.recipe.currentRecipe else { return }
            do {
                try await recipePersistenceService.saveRecipe(recipe)
                send(.recipe(.recipeSaved(recipe)))
                TipEvents.recipeSaved.sendDonation()
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

        case .approveSubstitution:
            // 保存済みレシピのカスタマイズなら自動保存
            // Reducer実行後、previewRecipe は currentRecipe に移動済みなので
            // currentRecipe（承認後のレシピ）が savedRecipes に存在するか確認
            if let currentRecipe = state.recipe.currentRecipe,
               state.recipe.savedRecipes.contains(where: { $0.id == currentRecipe.id }) {
                send(.recipe(.saveRecipe))
            }

        // MARK: Category Side Effects

        case .loadCategories:
            do {
                let result = try await recipePersistenceService.loadAllCategories()
                send(.recipe(.categoriesLoaded(result.categories, categoryRecipeMap: result.categoryRecipeMap)))
            } catch {
                send(.recipe(.categoriesLoadFailed(error.localizedDescription)))
            }

        case .createCategory(let name):
            do {
                let category = try await recipePersistenceService.createCategory(name: name)
                send(.recipe(.categoryCreated(category)))
            } catch {
                send(.recipe(.categoryCreateFailed(error.localizedDescription)))
            }

        case .renameCategory(let id, let newName):
            do {
                let category = try await recipePersistenceService.renameCategory(id: id, newName: newName)
                send(.recipe(.categoryRenamed(category)))
            } catch {
                send(.recipe(.categoryRenameFailed(error.localizedDescription)))
            }

        case .deleteCategory(let id):
            do {
                try await recipePersistenceService.deleteCategory(id: id)
                send(.recipe(.categoryDeleted(id: id)))
            } catch {
                send(.recipe(.categoryDeleteFailed(error.localizedDescription)))
            }

        case .addRecipeToCategory(let recipeID, let categoryID):
            do {
                try await recipePersistenceService.addRecipeToCategory(recipeID: recipeID, categoryID: categoryID)
                send(.recipe(.recipeCategoryUpdated(recipeID: recipeID, categoryID: categoryID, added: true)))
            } catch {
                send(.recipe(.recipeCategoryUpdateFailed(error.localizedDescription)))
            }

        case .removeRecipeFromCategory(let recipeID, let categoryID):
            do {
                try await recipePersistenceService.removeRecipeFromCategory(recipeID: recipeID, categoryID: categoryID)
                send(.recipe(.recipeCategoryUpdated(recipeID: recipeID, categoryID: categoryID, added: false)))
            } catch {
                send(.recipe(.recipeCategoryUpdateFailed(error.localizedDescription)))
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
                TipEvents.shoppingListCreated.sendDonation()
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
                if isChecked {
                    TipEvents.shoppingListItemChecked.sendDonation()
                }
            } catch {
                send(.shoppingList(.itemCheckUpdateFailed(error.localizedDescription)))
            }

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    // MARK: - Subscription Side Effects

    private func handleSubscriptionSideEffects(_ action: SubscriptionAction) async {
        switch action {
        case .showPaywall:
            TipEvents.paywallViewed.sendDonation()

        case .loadSubscriptionStatus:
            do {
                let isPremium = try await revenueCatService.checkPremiumStatus()
                send(.subscription(.subscriptionStatusLoaded(isPremium: isPremium)))
            } catch {
                send(.subscription(.subscriptionStatusLoadFailed(error.localizedDescription)))
            }

        case .loadPackages:
            do {
                let packages = try await revenueCatService.fetchPackages()
                send(.subscription(.packagesLoaded(packages)))
            } catch {
                send(.subscription(.packagesLoadFailed(error.localizedDescription)))
            }

        case .purchase(let packageID):
            do {
                let result = try await revenueCatService.purchase(packageID: packageID)
                switch result {
                case .success:
                    send(.subscription(.purchaseSucceeded))
                case .cancelled:
                    send(.subscription(.purchaseCancelled))
                }
            } catch {
                send(.subscription(.purchaseFailed(error.localizedDescription)))
            }

        case .restorePurchases:
            do {
                let isPremium = try await revenueCatService.restorePurchases()
                send(.subscription(.restoreSucceeded(isPremium: isPremium)))
            } catch {
                send(.subscription(.restoreFailed(error.localizedDescription)))
            }

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    // MARK: - Debug Side Effects

    #if DEBUG
    private func handleDebugSideEffects(_ action: DebugAction) async {
        switch action {
        case .switchStore(let useTestStore):
            // UserDefaultsに設定を保存
            DebugSettings.shared.useTestStore = useTestStore
            send(.debug(.storeSwitched))

        case .resetUser:
            do {
                _ = try await Purchases.shared.logOut()
                send(.debug(.userReset))
                // サブスクリプション状態を再読み込み
                send(.subscription(.loadSubscriptionStatus))
            } catch {
                send(.debug(.operationFailed(error.localizedDescription)))
            }

        case .deleteAllData:
            do {
                try await recipePersistenceService.deleteAllData()
                send(.debug(.dataDeleted))
                // リストを空にリロード
                send(.recipe(.savedRecipesLoaded([])))
                send(.recipe(.categoriesLoaded([], categoryRecipeMap: [:])))
                send(.shoppingList(.shoppingListsLoaded([])))
            } catch {
                send(.debug(.operationFailed(error.localizedDescription)))
            }

        case .resetSeedData:
            SeedDataService.resetSeedFlag()
            send(.debug(.seedDataReset))

        default:
            // その他のアクションは副作用なし
            break
        }
    }
    #endif
}
