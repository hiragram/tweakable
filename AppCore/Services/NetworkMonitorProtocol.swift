import Foundation

/// ネットワーク接続状態を監視するプロトコル
public protocol NetworkMonitorProtocol: Sendable {
    /// 現在ネットワーク接続があるかどうか
    var isConnected: Bool { get async }

    /// 接続状態の変更を監視するストリーム
    var connectionUpdates: AsyncStream<Bool> { get }
}
