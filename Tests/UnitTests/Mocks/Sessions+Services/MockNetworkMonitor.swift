@testable import OneLogin

final class MockNetworkMonitor: NetworkMonitoring {
    static let shared: NetworkMonitoring = MockNetworkMonitor()
    var isConnected: Bool = true
    
    init() { }
}
