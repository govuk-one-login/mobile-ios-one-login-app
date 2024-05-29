import Networking

struct MockAuthenticationProvider: AuthenticationProvider {
    let bearerToken: String = "testBearerToken"
}
