import Foundation
import Testing
@testable import AppCore

/// AppStoreのboot処理に関するテスト
@MainActor
@Suite
struct AppStoreBootTests {
    // MARK: - 再インストール検知のテスト

    @Test
    func boot_firstLaunch_clearsSessionAndSetsFlag() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let mockDefaults = MockUserDefaults()
        // hasLaunchedBefore = false（初回起動）
        mockDefaults.storage["hasLaunchedBefore"] = false

        let store = AppStore(
            supabaseClient: mockClient,
            userDefaults: mockDefaults
        )

        // Act
        store.send(.boot)

        // 副作用が実行されるのを待つ
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        #expect(mockClient.logoutCallCount == 1, "初回起動時はlogoutが呼ばれるべき")
        #expect(mockDefaults.storage["hasLaunchedBefore"] as? Bool == true, "フラグがtrueに設定されるべき")
    }

    @Test
    func boot_subsequentLaunch_doesNotClearSession() async throws {
        // Arrange
        let mockClient = MockSupabaseClient()
        let mockDefaults = MockUserDefaults()
        // hasLaunchedBefore = true（2回目以降）
        mockDefaults.storage["hasLaunchedBefore"] = true

        let store = AppStore(
            supabaseClient: mockClient,
            userDefaults: mockDefaults
        )

        // Act
        store.send(.boot)

        // 副作用が実行されるのを待つ
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        #expect(mockClient.logoutCallCount == 0, "2回目以降はlogoutが呼ばれないべき")
    }

    @Test
    func boot_withNilSupabaseClient_doesNotCrash() async throws {
        // Arrange
        let mockDefaults = MockUserDefaults()
        // hasLaunchedBefore = false（初回起動）
        mockDefaults.storage["hasLaunchedBefore"] = false

        let store = AppStore(
            supabaseClient: nil,
            userDefaults: mockDefaults
        )

        // Act
        store.send(.boot)

        // 副作用が実行されるのを待つ
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert - クラッシュしないこと、フラグは設定されること
        #expect(mockDefaults.storage["hasLaunchedBefore"] as? Bool == true)
    }
}
