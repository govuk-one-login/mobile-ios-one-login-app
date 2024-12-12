import AppIntegrity
import Authentication
import Foundation

extension LoginSession {
    func finalise(
        redirectURL url: URL,
        attestationStore: AttestationStorage = UserDefaults.standard,
        appIntegrityService: @escaping () throws -> AppIntegrityProvider = FirebaseAppIntegrityService.firebaseAppCheck
    ) async throws {
        var tokenHeaders: [String: String]?
        switch attestationStore.validAttestation {
        case .none:
            if AppEnvironment.appIntegrityEnabled {
                tokenHeaders = try await appIntegrityService().assertIntegrity()
            }
        case .some(let valid):
            switch valid {
            case true:
                tokenHeaders = [
                    TokenHeaderKey.attestationJWT.rawValue: try attestationStore.attestationJWT,
                    TokenHeaderKey.attestationPoP.rawValue: try appIntegrityService().proofTokenGenerator.token
                ]
            case false:
                if AppEnvironment.appIntegrityEnabled {
                    tokenHeaders = try await appIntegrityService().assertIntegrity()
                }
            }
        }
        try finalise(
            redirectURL: url,
            tokenParameters: nil,
            tokenHeaders: tokenHeaders
        )
    }
}
