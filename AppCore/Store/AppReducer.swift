import Foundation

/// アプリ全体のReducer
public enum AppReducer {
    /// 状態を更新する純粋関数
    public static func reduce(state: inout AppState, action: AppAction) {
        switch action {
        case .boot:
            // 起動時の状態変更なし
            break

        case .recipe(let recipeAction):
            RecipeReducer.reduce(state: &state.recipe, action: recipeAction)

        case .shoppingList(let shoppingListAction):
            ShoppingListReducer.reduce(state: &state.shoppingList, action: shoppingListAction)

        case .subscription(let subscriptionAction):
            SubscriptionReducer.reduce(state: &state.subscription, action: subscriptionAction)

        #if DEBUG
        case .debug(let debugAction):
            DebugReducer.reduce(state: &state.debug, action: debugAction)
        #endif
        }
    }
}
