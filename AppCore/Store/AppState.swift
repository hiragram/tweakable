import Foundation

/// アプリ全体の状態（Single Source of Truth）
public struct AppState: Equatable, Sendable {
    /// レシピ画面の状態
    public var recipe = RecipeState()

    /// 買い物リスト機能の状態
    public var shoppingList = ShoppingListState()

    /// サブスクリプション機能の状態
    public var subscription = SubscriptionState()

    #if DEBUG
    /// デバッグ機能の状態
    public var debug = DebugState()
    #endif

    public init() {}
}
