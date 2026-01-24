import Testing
import Foundation
@testable import AppCore

@Suite
struct NetworkMonitorTests {

    @Test
    func mockNetworkMonitor_isConnected_defaultsToTrue() async {
        let mock = MockNetworkMonitor()

        let result = await mock.isConnected

        #expect(result == true)
    }

    @Test
    func mockNetworkMonitor_setConnected_updatesIsConnected() async {
        let mock = MockNetworkMonitor()

        mock.setConnected(false)
        let result = await mock.isConnected

        #expect(result == false)
    }

    @Test
    func mockNetworkMonitor_setConnected_true_updatesIsConnected() async {
        let mock = MockNetworkMonitor()

        mock.setConnected(false)
        mock.setConnected(true)
        let result = await mock.isConnected

        #expect(result == true)
    }
}
