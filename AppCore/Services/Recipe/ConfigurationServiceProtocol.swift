import Foundation

/// 設定取得サービスのプロトコル
public protocol ConfigurationServiceProtocol: Sendable {
    /// OpenAI APIキーを取得
    func getOpenAIAPIKey() async -> String?

    /// OpenAIモデル名を取得
    func getOpenAIModel() async -> String
}
