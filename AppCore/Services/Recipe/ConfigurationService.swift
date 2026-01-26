import Foundation

/// 設定取得サービスの実装
/// DEBUG時は環境変数から、Release時はFirebase Remote Configから取得
public struct ConfigurationService: ConfigurationServiceProtocol, Sendable {

    public init() {}

    public func getOpenAIAPIKey() async -> String? {
        #if DEBUG
        // DEBUG時は環境変数から取得
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        #else
        // TODO: 本番ではFirebase Remote Configから取得する
        return nil
        #endif
    }

    public func getOpenAIModel() async -> String {
        // TODO: 本番ではFirebase Remote Configから取得する
        return "gpt-4.1-2025-04-14"
    }
}
