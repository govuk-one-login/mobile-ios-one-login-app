import AppIntegrity
import CryptoService
import Foundation
import TokenGeneration

extension CryptoSigningService: @retroactive ProofOfPossessionProvider, @retroactive JWTSigningService {
    public var publicKey: Data {
        get throws(AppIntegritySigningError) {
            do {
                return try publicKey(format: .jwk)
            } catch {
                throw AppIntegritySigningError(
                    errorType: .publicKeyJWTError,
                    errorDescription: error.localizedDescription
                )
            }
        }
    }
}

struct AppIntegritySigningError: Error, LocalizedError {
    enum AppIntegritySigningErrorType: String {
        case initialisationError = "error initialising the crypto signing service"
        case publicKeyJWTError = "error generating the public key in JWK format"
        case publicKeyDictionaryError = "error generating the public key as a dictionary"
        case unknown = "unknown AppIntegritySigningError"
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
