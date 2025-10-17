import AppIntegrity
import CryptoService
import Foundation
import Networking
import TokenGeneration

extension AppIntegrityProvider where Self == FirebaseAppIntegrityService {
    static func firebaseAppCheck() throws(AppIntegritySigningError) -> FirebaseAppIntegrityService {
        let configuration = CryptoServiceConfiguration(
            id: OLString.attestation,
            accessControlLevel: .open
        )
        do {
            let signingService = try CryptoSigningService(configuration: configuration)
            
            // MARK: PoP JWT
            let popJWTRepresentation = JWTRepresentation(header: AppIntegrityPoPJWT.headers(),
                                                         payload: AppIntegrityPoPJWT.payload())
            let popTokenGenerator = JWTGenerator(jwtRepresentation: popJWTRepresentation,
                                                 signingService: signingService)
            
            // MARK: DPoP JWT
            let dpopJWTRepresentation = JWTRepresentation(
                header: AppIntegrityDPoPJWT.headers(jwk: try signingService.jwkDictionary)(),
                payload: AppIntegrityDPoPJWT.payload()
            )
            let dPoPTokenGenerator = JWTGenerator(jwtRepresentation: dpopJWTRepresentation,
                                                  signingService: signingService)
            
            return FirebaseAppIntegrityService(
                networkClient: NetworkClient(),
                proofOfPossessionProvider: signingService,
                baseURL: AppEnvironment.mobileBaseURL,
                proofOfPossessionTokenGenerator: popTokenGenerator,
                demonstratingProofOfPossessionTokenGenerator: dPoPTokenGenerator,
                attestationStore: UserDefaults.standard
            )
        } catch let error as KeyPairAdministratorError {
            throw AppIntegritySigningError(
                errorType: .initialisationError,
                errorDescription: error.localizedDescription
            )
        } catch let error as SigningServiceError {
            throw AppIntegritySigningError(
                errorType: .publicKeyDictionaryError,
                errorDescription: error.localizedDescription
            )
        } catch {
            throw AppIntegritySigningError(
                errorType: .unknown,
                errorDescription: error.localizedDescription
            )
        }
    }
}
