import Testing
import Foundation
@testable import AppCore

@Suite
struct SupabaseAuthServiceTests {

    // MARK: - sendOTP Tests

    @Test
    func sendOTP_withValidEmail_returnsSuccess() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"

        // Act
        let result = try await service.sendOTP(to: email)

        // Assert
        #expect(result.success == true)
        #expect(result.email == email)
    }

    @Test
    func sendOTP_updatesStateToOtpSent() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"

        // Act
        _ = try await service.sendOTP(to: email)

        // Assert
        let state = await service.currentState
        #expect(state == .otpSent(email: email))
    }

    // MARK: - verifyOTP Tests

    @Test
    func verifyOTP_withValidOTP_returnsSuccessAndUserID() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let expectedUserID = UUID()
        mockClient.mockUserID = expectedUserID
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"
        let otp = "123456"

        // Act
        _ = try await service.sendOTP(to: email)
        let result = try await service.verifyOTP(otp, email: email)

        // Assert
        #expect(result.success == true)
        #expect(result.userID == expectedUserID)
    }

    @Test
    func verifyOTP_updatesStateToAuthenticated() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let expectedUserID = UUID()
        mockClient.mockUserID = expectedUserID
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"
        let otp = "123456"

        // Act
        _ = try await service.sendOTP(to: email)
        _ = try await service.verifyOTP(otp, email: email)

        // Assert
        let state = await service.currentState
        #expect(state == .authenticated(userID: expectedUserID))
    }

    @Test
    func verifyOTP_forNewUser_setsIsNewUserTrue() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        mockClient.mockUserID = UUID()
        mockClient.mockIsNewUser = true
        let service = SupabaseAuthService(client: mockClient)
        let email = "newuser@example.com"
        let otp = "123456"

        // Act
        _ = try await service.sendOTP(to: email)
        let result = try await service.verifyOTP(otp, email: email)

        // Assert
        #expect(result.isNewUser == true)
    }

    // MARK: - logout Tests

    @Test
    func logout_updatesStateToUnauthenticated() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        mockClient.mockUserID = UUID()
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"
        let otp = "123456"

        // 先にログイン
        _ = try await service.sendOTP(to: email)
        _ = try await service.verifyOTP(otp, email: email)

        // Act
        try await service.logout()

        // Assert
        let state = await service.currentState
        #expect(state == .unauthenticated)
    }

    @Test
    func logout_clearsCurrentUserID() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        mockClient.mockUserID = UUID()
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"
        let otp = "123456"

        // 先にログイン
        _ = try await service.sendOTP(to: email)
        _ = try await service.verifyOTP(otp, email: email)

        // Act
        try await service.logout()

        // Assert
        let userID = await service.currentUserID
        #expect(userID == nil)
    }

    // MARK: - currentUserID Tests

    @Test
    func currentUserID_whenAuthenticated_returnsUserID() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let expectedUserID = UUID()
        mockClient.mockUserID = expectedUserID
        let service = SupabaseAuthService(client: mockClient)
        let email = "test@example.com"
        let otp = "123456"

        // Act
        _ = try await service.sendOTP(to: email)
        _ = try await service.verifyOTP(otp, email: email)

        // Assert
        let userID = await service.currentUserID
        #expect(userID == expectedUserID)
    }

    @Test
    func currentUserID_whenUnauthenticated_returnsNil() async {
        // Arrange
        let mockClient = MockSupabaseClient()
        let service = SupabaseAuthService(client: mockClient)

        // Act
        let userID = await service.currentUserID

        // Assert
        #expect(userID == nil)
    }

    // MARK: - restoreSession Tests

    @Test
    func restoreSession_withValidSession_returnsUserID() async {
        // Arrange
        let mockClient = MockSupabaseClient()
        let expectedUserID = UUID()
        mockClient.mockStoredUserID = expectedUserID
        let service = SupabaseAuthService(client: mockClient)

        // Act
        let userID = await service.restoreSession()

        // Assert
        #expect(userID == expectedUserID)
    }

    @Test
    func restoreSession_withNoSession_returnsNil() async {
        // Arrange
        let mockClient = MockSupabaseClient()
        mockClient.mockStoredUserID = nil
        let service = SupabaseAuthService(client: mockClient)

        // Act
        let userID = await service.restoreSession()

        // Assert
        #expect(userID == nil)
    }

    @Test
    func restoreSession_updatesStateToAuthenticated() async {
        // Arrange
        let mockClient = MockSupabaseClient()
        let expectedUserID = UUID()
        mockClient.mockStoredUserID = expectedUserID
        let service = SupabaseAuthService(client: mockClient)

        // Act
        _ = await service.restoreSession()

        // Assert
        let state = await service.currentState
        #expect(state == .authenticated(userID: expectedUserID))
    }
}
