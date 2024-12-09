import AppIntegrity
import Authentication
@testable import OneLogin

struct MockLoginSessionConfiguration {
    @Sendable
    static func oneLoginSessionConfiguration(
        persistentSessionID: String? = nil
    ) async throws -> LoginSessionConfiguration {
        LoginSessionConfiguration(
            authorizationEndpoint: AppEnvironment.stsAuthorize,
            tokenEndpoint: AppEnvironment.stsToken,
            clientID: AppEnvironment.stsClientID,
            redirectURI: AppEnvironment.mobileRedirect.absoluteString,
            persistentSessionId: "123456789",
            tokenHeaders: ["mock_token_header_key": "mock_token_header_value"]
        )
    }
}
