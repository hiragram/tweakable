import Foundation
import Network

/// ネットワーク状態監視の実装
public actor NetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private var _isConnected: Bool = true  // デフォルトはtrue（楽観的）
    private var continuation: AsyncStream<Bool>.Continuation?
    private var hasStarted = false

    public var isConnected: Bool {
        _isConnected
    }

    public nonisolated var connectionUpdates: AsyncStream<Bool> {
        AsyncStream { continuation in
            Task {
                await self.setContinuation(continuation)
            }
        }
    }

    public init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "NetworkMonitor")
    }

    /// 監視を開始
    public func startMonitoring() {
        startMonitoringInternal()
    }

    private func startMonitoringInternal() {
        guard !hasStarted else { return }
        hasStarted = true

        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updateConnectionStatus(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }

    /// 監視を停止
    public func stopMonitoring() {
        monitor.cancel()
        continuation?.finish()
    }

    private func setContinuation(_ cont: AsyncStream<Bool>.Continuation) {
        self.continuation = cont
    }

    private func updateConnectionStatus(_ connected: Bool) {
        _isConnected = connected
        continuation?.yield(connected)
    }
}
