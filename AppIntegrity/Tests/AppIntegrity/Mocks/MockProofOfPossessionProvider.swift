import AppIntegrity
import Foundation

final class MockProofOfPossessionProvider: ProofOfPossessionProvider {
    var errorFromPublicKey: Error?
    
    var publicKey: Data {
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
    
    func sign(data: Data) -> Data {
        Data()
    }
}
