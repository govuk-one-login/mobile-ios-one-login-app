import Network

final class NetworkMonitor {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init(isConnected: Bool = false) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected!")
                self.isConnected = true
            } else {
                self.isConnected = false
                print("Houston we are offline")
            }
        }
        monitor.start(queue: queue)
    }

    func checkNetworkConnection() -> Bool {
        return isConnected
    }
}
