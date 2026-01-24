import Foundation

/// 認証画面のUI状態
public struct AuthUIState: Equatable, Sendable {
    /// メールアドレス入力中のテキスト
    public var email: String = ""

    /// OTP入力中のテキスト
    public var otp: String = ""

    /// OTP送信中かどうか
    public var isSendingOTP: Bool = false

    /// OTP検証中かどうか
    public var isVerifyingOTP: Bool = false

    /// エラーメッセージ
    public var errorMessage: String?

    /// OTP送信済みかどうか
    public var otpSent: Bool = false

    /// 認証済みユーザーID
    public var authenticatedUserID: UUID?

    /// 新規ユーザーかどうか
    public var isNewUser: Bool = false

    public init() {}
}
