import Network

protocol NetworkMonitoring {
    var isConnected: Bool { get set }
    var isConnectedToVPN: Bool { get set }
}
