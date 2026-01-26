import FirebaseRemoteConfig
import Foundation

/// 設定取得サービスの実装
/// Firebase Remote Configから設定値を取得する
public struct ConfigurationService: ConfigurationServiceProtocol, Sendable {

    public init() {}

    public func getOpenAIAPIKey() async -> String? {
        await fetchAndActivateIfNeeded()
        let value = RemoteConfig.remoteConfig().configValue(forKey: Keys.openaiAPIKey).stringValue
        return value.isEmpty ? nil : value
    }

    public func getOpenAIModel() async -> String {
        await fetchAndActivateIfNeeded()
        let value = RemoteConfig.remoteConfig().configValue(forKey: Keys.openaiModel).stringValue
        return value.isEmpty ? Defaults.openaiModel : value
    }

    // MARK: - Private

    private enum Keys {
        static let openaiAPIKey = "openai_api_key"
        static let openaiModel = "openai_model"
    }

    private enum Defaults {
        static let openaiModel = "gpt-4.1-2025-04-14"
    }

    private func fetchAndActivateIfNeeded() async {
        let remoteConfig = RemoteConfig.remoteConfig()

        #if DEBUG
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        #endif

        do {
            _ = try await remoteConfig.fetchAndActivate()
        } catch {
            // フェッチ失敗時はキャッシュ値を使用
        }
    }
}
