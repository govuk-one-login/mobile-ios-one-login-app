import AppIntegrity
import CryptoService
import Foundation
import Networking
import TokenGeneration

extension AppIntegrityProvider where Self == FirebaseAppIntegrityService {
    static func firebaseAppCheck() throws -> FirebaseAppIntegrityService {
        let configuration = CryptoServiceConfiguration(
            id: OLString.attestation,
            accessControlLevel: .open
        )
        do {
            let signingService = try CryptoSigningService(configuration: configuration)
            
            // MARK: DPoP JWT
            let dpopJWTRepresentation = JWTRepresentation(
                header: AppIntegrityDPoPJWT.headers(jwk: try signingService.jwkDictionary)(),
                payload: AppIntegrityDPoPJWT.payload()
            )
            let dPoPTokenGenerator = JWTGenerator(jwtRepresentation: dpopJWTRepresentation,
                                                  signingService: signingService)
            
            // MARK: PoP JWT
            let popJWTRepresentation = JWTRepresentation(header: AppIntegrityPoPJWT.headers(),
                                                         payload: AppIntegrityPoPJWT.payload())
            let popTokenGenerator = JWTGenerator(jwtRepresentation: popJWTRepresentation,
                                                 signingService: signingService)
            
            return FirebaseAppIntegrityService(
                networkClient: NetworkClient(),
                proofOfPossessionProvider: signingService,
                baseURL: AppEnvironment.mobileBaseURL,
                proofTokenGenerator: popTokenGenerator,
                dPoPTokenGenerator: dPoPTokenGenerator,
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
