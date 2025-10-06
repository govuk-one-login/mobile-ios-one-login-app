import AppIntegrity
import CryptoService
import Foundation
import TokenGeneration

extension CryptoSigningService: @retroactive ProofOfPossessionProvider, @retroactive JWTSigningService {
    public var publicKey: Data {
        get throws {
            do {
                return try publicKey(format: .jwk)
            } catch {
                throw AppIntegritySigningError(
                    errorType: .publicKeyError,
                    errorDescription: error.localizedDescription
                )
            }
        }
    }
}
