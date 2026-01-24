import Foundation
@testable import AppCore

/// テスト用のSupabaseクライアントモック
final class MockSupabaseClient: SupabaseClientProtocol, @unchecked Sendable {
    // MARK: - Mock Configuration

    /// モックで返すユーザーID（verifyOTP成功時）
    var mockUserID: UUID?

    /// モックで返すセッション復元用ユーザーID
    var mockStoredUserID: UUID?

    /// 新規ユーザーかどうか
    var mockIsNewUser: Bool = false

    /// エラーをシミュレートする場合に設定
    var shouldThrowError: Bool = false

    // MARK: - Call Tracking

    var sendOTPCallCount = 0
    var sendOTPLastEmail: String?

    var verifyOTPCallCount = 0
    var verifyOTPLastOTP: String?
    var verifyOTPLastEmail: String?

    var logoutCallCount = 0

    var restoreSessionCallCount = 0

    // MARK: - SupabaseClientProtocol

    func sendOTP(to email: String) async throws {
        sendOTPCallCount += 1
        sendOTPLastEmail = email

        if shouldThrowError {
            throw SupabaseClientError.networkError
        }
    }

    func verifyOTP(_ otp: String, email: String) async throws -> (userID: UUID, isNewUser: Bool) {
        verifyOTPCallCount += 1
        verifyOTPLastOTP = otp
        verifyOTPLastEmail = email

        if shouldThrowError {
            throw SupabaseClientError.invalidOTP
        }

        guard let userID = mockUserID else {
            throw SupabaseClientError.invalidOTP
        }

        return (userID, mockIsNewUser)
    }

    func logout() async throws {
        logoutCallCount += 1

        if shouldThrowError {
            throw SupabaseClientError.networkError
        }
    }

    func restoreSession() async -> UUID? {
        restoreSessionCallCount += 1
        return mockStoredUserID
    }
}
