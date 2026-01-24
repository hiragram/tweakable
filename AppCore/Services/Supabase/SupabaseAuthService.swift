import Foundation

/// Supabase認証サービス
/// テスト可能にするため、SupabaseClientProtocolに依存
public actor SupabaseAuthService: SupabaseAuthServiceProtocol {
    private let client: SupabaseClientProtocol
    private var state: AuthState = .unauthenticated
    private var userID: UUID?

    public init(client: SupabaseClientProtocol) {
        self.client = client
    }

    // MARK: - SupabaseAuthServiceProtocol

    public var currentState: AuthState {
        state
    }

    public var currentUserID: UUID? {
        userID
    }

    public func sendOTP(to email: String) async throws -> OTPSendResult {
        try await client.sendOTP(to: email)
        state = .otpSent(email: email)
        return OTPSendResult(success: true, email: email)
    }

    public func verifyOTP(_ otp: String, email: String) async throws -> OTPVerifyResult {
        let result = try await client.verifyOTP(otp, email: email)
        userID = result.userID
        state = .authenticated(userID: result.userID)
        return OTPVerifyResult(success: true, userID: result.userID, isNewUser: result.isNewUser)
    }

    public func logout() async throws {
        try await client.logout()
        userID = nil
        state = .unauthenticated
    }

    public func restoreSession() async -> UUID? {
        guard let restoredUserID = await client.restoreSession() else {
            return nil
        }
        userID = restoredUserID
        state = .authenticated(userID: restoredUserID)
        return restoredUserID
    }
}
