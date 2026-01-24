import Foundation
import Supabase

/// 実際のSupabaseクライアント
/// supabase-swiftをラップして、テスト可能なプロトコルに準拠
public final class SupabaseClientWrapper: SupabaseClientProtocol, @unchecked Sendable {
    private let client: Supabase.SupabaseClient

    public init(supabaseURL: URL, supabaseKey: String) {
        self.client = Supabase.SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }

    // MARK: - SupabaseClientProtocol

    public func sendOTP(to email: String) async throws {
        do {
            try await client.auth.signInWithOTP(email: email)
        } catch {
            throw mapError(error)
        }
    }

    public func verifyOTP(_ otp: String, email: String) async throws -> (userID: UUID, isNewUser: Bool) {
        do {
            let session = try await client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .email
            )
            let isNewUser = isUserNew(session.user)
            return (session.user.id, isNewUser)
        } catch {
            throw mapError(error)
        }
    }

    public func logout() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw mapError(error)
        }
    }

    public func restoreSession() async -> UUID? {
        do {
            let session = try await client.auth.session
            return session.user.id
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func isUserNew(_ user: Supabase.User) -> Bool {
        // createdAtとupdatedAtが同じか、ほぼ同じ場合は新規ユーザー
        // 1秒以内の差であれば新規ユーザーと判定
        return abs(user.createdAt.timeIntervalSince(user.updatedAt)) < 1.0
    }

    private func mapError(_ error: Error) -> SupabaseClientError {
        let errorDescription = error.localizedDescription.lowercased()

        if errorDescription.contains("network") || errorDescription.contains("connection") {
            return .networkError
        }

        if errorDescription.contains("otp") || errorDescription.contains("token") || errorDescription.contains("invalid") {
            return .invalidOTP
        }

        if errorDescription.contains("session") || errorDescription.contains("expired") {
            return .sessionExpired
        }

        return .unknown(error.localizedDescription)
    }
}
