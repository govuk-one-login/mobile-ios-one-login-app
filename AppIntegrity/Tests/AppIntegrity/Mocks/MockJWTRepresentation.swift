@testable import AppIntegrity

struct MockJWTRepresentation: JWTRepresentation {
    var header: [String: Any]
    var payload: [String: Any]
}
