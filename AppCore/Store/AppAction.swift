import Foundation

/// アプリ全体のアクション
public enum AppAction: Sendable {
    /// アプリ起動時の初期化
    case boot

    /// レシピ画面のアクション
    case recipe(RecipeAction)

    /// 買い物リスト機能のアクション
    case shoppingList(ShoppingListAction)

    /// サブスクリプション機能のアクション
    case subscription(SubscriptionAction)

    #if DEBUG
    /// デバッグ機能のアクション
    case debug(DebugAction)
    #endif
}
