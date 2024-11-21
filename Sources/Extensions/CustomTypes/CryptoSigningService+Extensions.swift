import Foundation
import TokenGeneration
import CryptoService
import AppIntegrity

extension CryptoSigningService: @retroactive ProofOfPossessionProvider, @retroactive JWTSigningService {
    public var publicKey: Data {
        get throws {
            try publicKey(format: .jwk)
        }
    }
}
