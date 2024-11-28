import AppIntegrity
import Authentication
import Foundation

protocol LoginSessionConfigurationProvider {
    static func oneLoginWithAppIntegrity(
        persistentSessionId: String?,
        appIntegrityService: AppIntegrityProvider
    ) async throws -> LoginSessionConfiguration
    
    static func oneLogin(
        persistentSessionId: String?,
        tokenHeaders: [String: String]?
    ) -> LoginSessionConfiguration
}

extension LoginSessionConfiguration: LoginSessionConfigurationProvider { }

extension LoginSessionConfiguration {
    static func oneLoginWithAppIntegrity(
        persistentSessionId: String? = nil,
        appIntegrityService: AppIntegrityProvider
    ) async throws -> Self {
        let attestationHeaders = try await appIntegrityService.assertIntegrity()
        return oneLogin(persistentSessionId: persistentSessionId, tokenHeaders: attestationHeaders)
    }
    
    static func oneLogin(
        persistentSessionId: String? = nil,
        tokenHeaders: [String: String]? = nil
    ) -> Self {
        let env = AppEnvironment.self
        return .init(authorizationEndpoint: env.callingSTSEnabled ? env.stsAuthorize : env.oneLoginAuthorize,
                     tokenEndpoint: env.callingSTSEnabled ? env.stsToken : env.oneLoginToken,
                     scopes: [.openid],
                     clientID: env.callingSTSEnabled ? env.stsClientID : env.oneLoginClientID,
                     redirectURI: env.oneLoginRedirect,
                     locale: env.isLocaleWelsh ? .cy : .en,
                     persistentSessionId: persistentSessionId,
                     tokenHeaders: tokenHeaders)
    }
}
