import Networking

struct MockAuthenticationProvider: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        "testBearerToken"
    }
}
