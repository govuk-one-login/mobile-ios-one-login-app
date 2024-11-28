import AppIntegrity
import Authentication
@testable import OneLogin

struct MockLoginSessionConfigurationInitialiser: LoginSessionConfigurationProvider {
    static func oneLoginWithAppIntegrity(
        persistentSessionId: String?,
        appIntegrityService: any AppIntegrityProvider
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
    
    static func oneLogin(
        persistentSessionId: String?,
        tokenHeaders: [String: String]?
    ) -> LoginSessionConfiguration {
        LoginSessionConfiguration(
            authorizationEndpoint: AppEnvironment.stsAuthorize,
            tokenEndpoint: AppEnvironment.stsToken,
            clientID: AppEnvironment.stsClientID,
            redirectURI: AppEnvironment.mobileRedirect.absoluteString,
            persistentSessionId: "123456789"
        )
    }
}
