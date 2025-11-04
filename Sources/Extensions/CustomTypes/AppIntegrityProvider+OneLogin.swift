import AppIntegrity
import CryptoService
import Foundation
import Networking
import TokenGeneration

extension AppIntegrityProvider where Self == FirebaseAppIntegrityService {
    static func firebaseAppCheck() throws(AppIntegritySigningError) -> FirebaseAppIntegrityService {
        let configuration = CryptoServiceConfiguration(
            id: OLString.attestationStore,
            accessControlLevel: .open
        )
        do {
            let attestationProvider = try CryptoSigningService(configuration: configuration)
            
            // MARK: Attestation Proof of Posession JWT
            let attestationPoPTokenGenerator = JWTGenerator(
                jwtRepresentation: AppIntegrityPoPJWTContent(),
                signingService: attestationProvider
            )

            // MARK: Demonstrating Proof of Possession JWT
            let demonstatringPoPJWTRepresentation = AppIntegrityDPoPJWTContent(
                jwk: try attestationProvider.jwkDictionary
            )
            let demonstatringPoPTokenGenerator = JWTGenerator(jwtRepresentation: demonstatringPoPJWTRepresentation,
                                                              signingService: attestationProvider)
            
            return FirebaseAppIntegrityService(
                attestationProofOfPossessionProvider: attestationProvider,
                attestationProofOfPossessionTokenGenerator: attestationPoPTokenGenerator,
                demonstratingProofOfPossessionTokenGenerator: demonstatringPoPTokenGenerator,
                attestationStore: SecureAttestationStore(),
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
