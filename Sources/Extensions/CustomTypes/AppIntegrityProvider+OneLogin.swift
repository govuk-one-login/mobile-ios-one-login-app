import AppIntegrity
import CryptoService
import Foundation
import Networking
import TokenGeneration

extension AppIntegrityProvider where Self == FirebaseAppIntegrityService {
    static func firebaseAppCheck() throws -> FirebaseAppIntegrityService {
        let configuration = CryptoServiceConfiguration(id: OLString.attestation, accessControlLevel: .open)
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
    }
}
