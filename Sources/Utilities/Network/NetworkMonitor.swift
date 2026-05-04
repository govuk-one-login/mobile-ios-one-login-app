import Network

final class NetworkMonitor: NetworkMonitoring {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    var isConnected: Bool = false
    var isConnectedToVPN: Bool = false

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            self.isConnectedToVPN = path.usesInterfaceType(.other)
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
