import Foundation

/// アプリ全体の状態（Single Source of Truth）
public struct AppState: Equatable, Sendable {
    /// 画面状態
    public var screenState: ScreenState = .checkingAuth

    /// スケジュール機能の状態
    public var schedule = ScheduleState()

    /// ホーム画面の状態
    public var home = HomeState()

    /// 共有機能の状態
    public var sharing = SharingState()

    /// 担当者割り当て機能の状態
    public var assignment = AssignmentState()

    /// 自分の担当一覧の状態
    public var myAssignments = MyAssignmentsState()

    /// 認証状態
    public var auth = AuthUIState()

    /// レシピ画面の状態
    public var recipe = RecipeState()

    /// 買い物リスト機能の状態
    public var shoppingList = ShoppingListState()

    /// サブスクリプション機能の状態
    public var subscription = SubscriptionState()

    public init() {}
}

/// 画面状態
public enum ScreenState: Equatable, Sendable {
    // MARK: - Supabase Auth states
    /// 認証状態を確認中
    case checkingAuth
    /// ログイン画面（メールアドレス入力）
    case login
    /// OTP入力画面
    case otpVerification(email: String)

    // MARK: - App states
    case onboarding
    case groupSetup
    case main
}
