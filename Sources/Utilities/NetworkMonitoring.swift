import Network

protocol NetworkMonitoring {
    static var shared: NetworkMonitoring { get }
    var isConnected: Bool { get set }
    
}
