import AppIntegrity
import CryptoService
import Foundation
import Networking
import TokenGeneration

extension AppIntegrityProvider where Self == FirebaseAppIntegrityService {
    static func firebaseAppCheck(attestationStore: AttestationStorage) throws(AppIntegritySigningError) -> FirebaseAppIntegrityService {
        let configuration = CryptoServiceConfiguration(
            id: OLString.attestationStore,
            accessControlLevel: .open
        )
        do {
            let attestationProvider = try CryptoSigningService(configuration: configuration)
            
            // MARK: Attestation Proof of Posession JWT
            let attestationPoPJWTRepresentation = AppIntegrityPoPJWT()
            let attestationPoPTokenGenerator = JWTGenerator(jwtRepresentation: attestationPoPJWTRepresentation,
                                                            signingService: attestationProvider)
            
            // MARK: Demonstrating Proof of Possession JWT
            let demonstratingPoPJWTRepresentation = AppIntegrityDPoPJWT(jwk: try attestationProvider.jwkDictionary)
            let demonstratingPoPTokenGenerator = JWTGenerator(jwtRepresentation: demonstratingPoPJWTRepresentation,
                                                              signingService: attestationProvider)
            
            return FirebaseAppIntegrityService(
                attestationProofOfPossessionProvider: attestationProvider,
                attestationProofOfPossessionTokenGenerator: attestationPoPTokenGenerator,
                demonstratingProofOfPossessionTokenGenerator: demonstratingPoPTokenGenerator,
                attestationStore: attestationStore,
                networkClient: NetworkClient(),
                baseURL: AppEnvironment.mobileBaseURL
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
