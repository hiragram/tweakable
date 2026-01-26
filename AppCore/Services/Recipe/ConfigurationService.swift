import Foundation

/// 設定取得サービスの実装
/// DEBUG時は環境変数から、Release時はFirebase Remote Configから取得
public struct ConfigurationService: ConfigurationServiceProtocol, Sendable {

    public init() {}

    public func getOpenAIAPIKey() async -> String? {
        // TODO: 本番ではFirebase Remote Configから取得する
        return "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"
    }

    public func getOpenAIModel() async -> String {
        // TODO: 本番ではFirebase Remote Configから取得する
        return "gpt-4.1-2025-04-14"
    }
}
