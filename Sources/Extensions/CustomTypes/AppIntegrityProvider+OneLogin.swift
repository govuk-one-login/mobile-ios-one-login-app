import AppIntegrity
import CryptoService
import Foundation
import Networking
import TokenGeneration

struct AppIntegritySigningError: Error, LocalizedError {
    enum AppIntegritySigningErrorType: String {
        case initialisationError = "error initialising the crypto signing service"
        case publicKeyError = "error generating the public key in JWK format"
    }

    let errorType: AppIntegritySigningErrorType
    let errorDescription: String?
    let failureReason: String?

    init(
        errorType: AppIntegritySigningErrorType,
        errorDescription: String
    ) {
        self.errorType = errorType
        self.errorDescription = errorDescription
        self.failureReason = errorType.rawValue
    }
}

extension AppIntegrityProvider where Self == FirebaseAppIntegrityService {
    static func firebaseAppCheck() throws -> FirebaseAppIntegrityService {
        let configuration = CryptoServiceConfiguration(
            id: OLString.attestation,
            accessControlLevel: .open
        )
        do {
            let signingService = try CryptoSigningService(configuration: configuration)
            let jwtRepresentation = JWTRepresentation(header: AppIntegrityJWT.headers(),
                                                      payload: AppIntegrityJWT.payload())
            let proofTokenGenerator = JWTGenerator(jwtRepresentation: jwtRepresentation,
                                                   signingService: signingService)
            return FirebaseAppIntegrityService(
                networkClient: NetworkClient(),
                proofOfPossessionProvider: signingService,
                baseURL: AppEnvironment.mobileBaseURL,
                proofTokenGenerator: proofTokenGenerator,
                attestationStore: UserDefaults.standard
            )
        } catch {
            throw AppIntegritySigningError(
                errorType: .initialisationError,
                errorDescription: error.localizedDescription
            )
        }
    }
}
