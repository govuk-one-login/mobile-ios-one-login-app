#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif


final class MockNetworkMonitor: NetworkMonitoring {
    var isConnected: Bool = true
}
