import Network

final class NetworkMonitor: NetworkMonitoring {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
