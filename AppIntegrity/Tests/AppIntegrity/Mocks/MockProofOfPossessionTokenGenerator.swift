@testable import AppIntegrity

class MockProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator {
    var header = [String: Any]()
    var payload = [String: Any]()
    
    var errorFromToken: Error?
    
    var token: String {
        get throws {
            if let errorFromToken {
                throw errorFromToken
            } else {
                return header.merging(payload) { $1 }.description
            }
        }
    }
}
