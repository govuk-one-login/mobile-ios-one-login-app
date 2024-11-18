public protocol JWTRepresentation {
    var header: [String: Any] { get }
    var payload: [String: Any] { get }
}
