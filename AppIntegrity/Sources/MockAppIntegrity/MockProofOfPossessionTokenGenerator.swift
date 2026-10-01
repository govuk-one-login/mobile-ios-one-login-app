import AppIntegrity

public final class MockProofOfPossessionTokenGenerator: ProofOfPossessionTokenGenerator {
    public var header = [String: Any]()
    public var payload = [String: Any]()
    
    public var errorFromToken: Error?
    
    public var token: String {
        get throws {
            if let errorFromToken {
                throw errorFromToken
            } else {
                return header.merging(payload) { $1 }.description
            }
        }
    }
    
    public init(header: [String : Any] = [String: Any](), payload: [String : Any] = [String: Any](), errorFromToken: Error? = nil) {
        self.header = header
        self.payload = payload
        self.errorFromToken = errorFromToken
    }
}
