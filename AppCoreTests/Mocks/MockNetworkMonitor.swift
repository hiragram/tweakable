import Foundation
@testable import AppCore

/// NetworkMonitorのMock実装
final class MockNetworkMonitor: NetworkMonitorProtocol, @unchecked Sendable {
    private var _isConnected: Bool = true
    private var continuation: AsyncStream<Bool>.Continuation?
    private let _connectionUpdates: AsyncStream<Bool>

    var isConnected: Bool {
        get async { _isConnected }
    }

    var connectionUpdates: AsyncStream<Bool> {
        _connectionUpdates
    }

    init() {
        var continuation: AsyncStream<Bool>.Continuation?
        _connectionUpdates = AsyncStream { cont in
            continuation = cont
        }
        self.continuation = continuation
    }

    /// テスト用: 接続状態を設定
    func setConnected(_ connected: Bool) {
        _isConnected = connected
        continuation?.yield(connected)
    }
}
