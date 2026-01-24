import Foundation

/// 認証関連のアクション
public enum AuthAction: Sendable {
    // MARK: - Session

    /// セッション復元を開始
    case restoreSession

    /// セッション復元完了
    case sessionRestored(userID: UUID?)

    // MARK: - OTP Flow

    /// メールアドレスを入力
    case updateEmail(String)

    /// OTPを送信
    case sendOTP

    /// OTP送信開始
    case sendingOTP

    /// OTP送信成功
    case otpSent(email: String)

    /// OTPを入力
    case updateOTP(String)

    /// OTPを検証
    case verifyOTP

    /// OTP検証開始
    case verifyingOTP

    /// OTP検証成功
    case otpVerified(userID: UUID, isNewUser: Bool)

    // MARK: - User Data Loading (Supabase)

    /// ユーザーデータのロードを開始（プロフィール、グループ）
    case loadUserData

    /// ユーザーデータのロード完了
    case userDataLoaded(profile: Profile?, groups: [SupabaseUserGroup])

    // MARK: - Logout

    /// ログアウト
    case logout

    /// ログアウト完了
    case loggedOut

    // MARK: - Error

    /// エラー発生
    case errorOccurred(String)

    /// エラーをクリア
    case clearError
}
