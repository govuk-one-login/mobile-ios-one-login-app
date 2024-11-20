@testable import AppIntegrity

struct MockProofTokenGenerator: ProofTokenGenerator {
    let header: [ String: Any ]
    let payload: [ String: Any ]
    
    var token: String {
        let body = header
        let combined = body.merging(payload) {
            $1
        }
        return "\(combined)"
    }
}
