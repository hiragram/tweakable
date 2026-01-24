import Foundation

/// 認証状態
public enum AuthState: Sendable, Equatable {
    /// 未認証
    case unauthenticated
    /// OTP送信済み（検証待ち）
    case otpSent(email: String)
    /// 認証済み
    case authenticated(userID: UUID)
}

/// OTP送信結果
public struct OTPSendResult: Sendable, Equatable {
    public let success: Bool
    public let email: String

    public init(success: Bool, email: String) {
        self.success = success
        self.email = email
    }
}

/// OTP検証結果
public struct OTPVerifyResult: Sendable, Equatable {
    public let success: Bool
    public let userID: UUID?
    public let isNewUser: Bool

    public init(success: Bool, userID: UUID?, isNewUser: Bool) {
        self.success = success
        self.userID = userID
        self.isNewUser = isNewUser
    }
}

/// Supabase認証サービスプロトコル
public protocol SupabaseAuthServiceProtocol: Sendable {
    /// 現在の認証状態を取得
    var currentState: AuthState { get async }

    /// 現在のユーザーIDを取得（認証済みの場合のみ）
    var currentUserID: UUID? { get async }

    /// メールアドレスにOTPを送信
    /// - Parameter email: 送信先メールアドレス
    /// - Returns: 送信結果
    func sendOTP(to email: String) async throws -> OTPSendResult

    /// OTPを検証してログイン
    /// - Parameters:
    ///   - otp: 6桁のOTPコード
    ///   - email: OTP送信先のメールアドレス
    /// - Returns: 検証結果
    func verifyOTP(_ otp: String, email: String) async throws -> OTPVerifyResult

    /// ログアウト
    func logout() async throws

    /// セッションを復元（アプリ起動時に呼び出す）
    /// - Returns: 復元成功した場合はユーザーID、失敗した場合はnil
    func restoreSession() async -> UUID?
}
