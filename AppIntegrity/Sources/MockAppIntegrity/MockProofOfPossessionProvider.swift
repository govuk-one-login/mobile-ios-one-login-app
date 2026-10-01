import AppIntegrity
import Foundation

public final class MockProofOfPossessionProvider: ProofOfPossessionProvider {
    public var errorFromPublicKey: Error?
    
    public var publicKey: Data {
        get throws {
            if let errorFromPublicKey {
                throw errorFromPublicKey
            } else {
                Data("""
                    {
                      "jwk": {
                        "kty": EC",
                        "use": "sig",
                        "crv": "P-256",
                        "x": "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM",
                        "y": "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA"
                      }
                    }
                """.utf8)
            }
        }
    }
    
    public init(errorFromPublicKey: Error? = nil) {
        self.errorFromPublicKey = errorFromPublicKey
    }
    
    func sign(data: Data) -> Data {
        Data()
    }
}
