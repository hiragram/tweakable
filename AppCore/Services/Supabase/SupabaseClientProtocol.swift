import Foundation

/// Supabaseクライアントエラー
public enum SupabaseClientError: Error, Sendable, Equatable, LocalizedError {
    case networkError
    case invalidOTP
    case sessionExpired
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .invalidOTP:
            return "認証コードが正しくありません"
        case .sessionExpired:
            return "セッションが期限切れです"
        case .unknown(let message):
            return message
        }
    }
}

/// Supabaseクライアントプロトコル
/// 実際のSupabaseClientをラップしてテスト可能にする
public protocol SupabaseClientProtocol: Sendable {
    /// メールアドレスにOTPを送信
    func sendOTP(to email: String) async throws

    /// OTPを検証してログイン
    func verifyOTP(_ otp: String, email: String) async throws -> (userID: UUID, isNewUser: Bool)

    /// ログアウト
    func logout() async throws

    /// セッションを復元
    func restoreSession() async -> UUID?
}
