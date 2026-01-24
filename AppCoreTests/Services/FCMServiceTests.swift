//
//  FCMServiceTests.swift
//  AppCoreTests
//
//  Created by Claude on 2026/01/12.
//

import Testing
import Foundation
@testable import AppCore

@Suite
struct FCMServiceTests {

    // MARK: - getToken Tests

    @Test
    func getToken_returnsToken() async throws {
        // Arrange
        let mockService = MockFCMService()
        mockService.stubbedToken = "test-token-abc123"

        // Act
        let token = try await mockService.getToken()

        // Assert
        #expect(token == "test-token-abc123")
        #expect(mockService.getTokenCallCount == 1)
    }

    @Test
    func getToken_throwsWhenNotAvailable() async throws {
        // Arrange
        let mockService = MockFCMService()
        mockService.shouldThrowOnGetToken = true

        // Act & Assert
        do {
            _ = try await mockService.getToken()
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error is FCMServiceError)
        }
    }

    // MARK: - saveToken Tests

    @Test
    func saveToken_savesTokenWithUserID() async throws {
        // Arrange
        let mockService = MockFCMService()
        let userID = UUID()
        let token = "saved-token-xyz789"

        // Act
        try await mockService.saveToken(token, userID: userID)

        // Assert
        #expect(mockService.saveTokenCallCount == 1)
        #expect(mockService.savedTokens.count == 1)
        #expect(mockService.savedTokens.first?.token == token)
        #expect(mockService.savedTokens.first?.userID == userID)
    }

    @Test
    func saveToken_throwsOnFailure() async throws {
        // Arrange
        let mockService = MockFCMService()
        mockService.shouldThrowOnSaveToken = true

        // Act & Assert
        do {
            try await mockService.saveToken("token", userID: UUID())
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error is FCMServiceError)
        }
    }

    // MARK: - observeTokenRefresh Tests

    @Test
    func observeTokenRefresh_registersHandler() async throws {
        // Arrange
        let mockService = MockFCMService()
        var receivedToken: String?

        // Act
        mockService.observeTokenRefresh { token in
            receivedToken = token
        }

        // Assert
        #expect(mockService.observeTokenRefreshCallCount == 1)

        // Simulate token refresh
        mockService.simulateTokenRefresh(newToken: "refreshed-token")
        #expect(receivedToken == "refreshed-token")
    }

    @Test
    func observeTokenRefresh_callsHandlerOnMultipleRefreshes() async throws {
        // Arrange
        let mockService = MockFCMService()
        var receivedTokens: [String] = []

        // Act
        mockService.observeTokenRefresh { token in
            receivedTokens.append(token)
        }

        mockService.simulateTokenRefresh(newToken: "token-1")
        mockService.simulateTokenRefresh(newToken: "token-2")

        // Assert
        #expect(receivedTokens.count == 2)
        #expect(receivedTokens[0] == "token-1")
        #expect(receivedTokens[1] == "token-2")
    }
}
