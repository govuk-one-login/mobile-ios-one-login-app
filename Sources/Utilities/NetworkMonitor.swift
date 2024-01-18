import Network

final class NetworkMonitor {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init(isConnected: Bool = false) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("User is online")
                self.isConnected = true
            } else {
                self.isConnected = false
                print("Houston we are offline")
            }
        }
        monitor.start(queue: queue)
    }
}
