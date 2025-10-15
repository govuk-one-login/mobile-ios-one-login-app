@testable import AppIntegrity

class MockProofTokenGenerator: ProofTokenGenerator {
    var header = [ String: Any ]()
    var payload = [ String: Any ]()
    
    var errorFromToken: Error?
    
    var token: String {
        get throws {
            if let errorFromToken {
                throw errorFromToken
            } else {
                let body = header
                let combined = body.merging(payload) {
                    $1
                }
                return "\(combined)"
            }
        }
    }
}
