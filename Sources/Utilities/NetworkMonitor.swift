import Network

final class NetworkMonitor: NetworkMonitoring {
    static let shared: NetworkMonitoring = NetworkMonitor()
    private let monitor = NWPathMonitor()
    var isConnected: Bool = false

    init() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected = true
            } else {
                self.isConnected = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
