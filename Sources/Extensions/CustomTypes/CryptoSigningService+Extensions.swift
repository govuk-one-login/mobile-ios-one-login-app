import AppIntegrity
import CryptoService
import Foundation
import TokenGeneration

extension CryptoSigningService: @retroactive ProofOfPossessionProvider, @retroactive JWTSigningService {
    public var publicKey: Data {
        get throws {
            try publicKey(format: .jwk)
        }
    }
}
