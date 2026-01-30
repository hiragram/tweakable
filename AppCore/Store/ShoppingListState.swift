import Foundation

// MARK: - ShoppingListState

/// 買い物リスト機能の状態
public struct ShoppingListState: Equatable, Sendable {
    /// 買い物リスト一覧
    public var shoppingLists: [ShoppingListDTO] = []

    /// 現在選択中の買い物リスト
    public var currentShoppingList: ShoppingListDTO?

    /// リスト一覧を読み込み中かどうか
    public var isLoadingLists: Bool = false

    /// リストを作成中かどうか
    public var isCreatingList: Bool = false

    /// リストを削除中かどうか
    public var isDeletingList: Bool = false

    /// アイテムを更新中かどうか
    public var isUpdatingItem: Bool = false

    /// エラーメッセージ
    public var errorMessage: String?

    public init() {}
}
