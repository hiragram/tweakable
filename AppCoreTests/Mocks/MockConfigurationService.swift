import Foundation
@testable import AppCore

/// ConfigurationServiceのMock実装
final class MockConfigurationService: ConfigurationServiceProtocol, @unchecked Sendable {
    /// テスト用: 返すAPIキー
    var apiKey: String?

    /// テスト用: 返すモデル名
    var model: String = "gpt-4o"

    init(apiKey: String? = "test-api-key", model: String = "gpt-4o") {
        self.apiKey = apiKey
        self.model = model
    }

    func getOpenAIAPIKey() async -> String? {
        return apiKey
    }

    func getOpenAIModel() async -> String {
        return model
    }
}
