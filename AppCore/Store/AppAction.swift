import Foundation

/// アプリ全体のアクション
public enum AppAction: Sendable {
    /// アプリ起動時の初期化
    /// AppStoreがSupabase認証フローを開始
    case boot

    /// 認証機能のアクション
    case auth(AuthAction)

    /// スケジュール機能のアクション
    case schedule(ScheduleAction)

    /// ホーム画面のアクション
    case home(HomeAction)

    /// 共有機能のアクション
    case sharing(SharingAction)

    /// 担当者割り当て機能のアクション
    case assignment(AssignmentAction)

    /// 自分の担当一覧のアクション
    case myAssignments(MyAssignmentsAction)

    /// レシピ画面のアクション
    case recipe(RecipeAction)

    /// 買い物リスト機能のアクション
    case shoppingList(ShoppingListAction)

    /// 画面遷移
    case setScreenState(ScreenState)
}
