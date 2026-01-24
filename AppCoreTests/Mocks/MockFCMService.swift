//
//  MockFCMService.swift
//  AppCoreTests
//
//  Created by Claude on 2026/01/12.
//

import Foundation
@testable import AppCore

/// テスト用のFCMServiceモック
final class MockFCMService: FCMServiceProtocol, @unchecked Sendable {

    // MARK: - Call Tracking

    var getTokenCallCount = 0
    var saveTokenCallCount = 0
    var observeTokenRefreshCallCount = 0

    // MARK: - Stubbed Values

    var stubbedToken: String = "mock-fcm-token-12345"
    var shouldThrowOnGetToken = false
    var shouldThrowOnSaveToken = false
    var savedTokens: [(token: String, userID: UUID)] = []
    private var tokenRefreshHandler: ((String) -> Void)?

    // MARK: - FCMServiceProtocol

    func getToken() async throws -> String {
        getTokenCallCount += 1
        if shouldThrowOnGetToken {
            throw FCMServiceError.tokenNotAvailable
        }
        return stubbedToken
    }

    func saveToken(_ token: String, userID: UUID) async throws {
        saveTokenCallCount += 1
        if shouldThrowOnSaveToken {
            throw FCMServiceError.saveFailed("Mock save failed")
        }
        savedTokens.append((token: token, userID: userID))
    }

    func observeTokenRefresh(_ handler: @escaping (String) -> Void) {
        observeTokenRefreshCallCount += 1
        tokenRefreshHandler = handler
    }

    // MARK: - Test Helpers

    /// テスト用：トークン更新をシミュレート
    func simulateTokenRefresh(newToken: String) {
        tokenRefreshHandler?(newToken)
    }
}
