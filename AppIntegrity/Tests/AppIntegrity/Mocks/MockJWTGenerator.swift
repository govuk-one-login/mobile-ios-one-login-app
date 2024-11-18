@testable import AppIntegrity

struct MockJWTGenerator: JWTGenerator {
    func generateJWT(header: [String: Any], payload: [String: Any]) -> String {
        ""
    }
}
