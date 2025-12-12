import Authentication
import Foundation

final class MockTokenResponse {
    enum DecodeError: Error {
        case invalid
    }
    
    func getJSONData(outdated: Bool = false) throws -> TokenResponse {
        let bundleForTest = Bundle(for: type(of: self))
        guard let jsonPath = bundleForTest.path(forResource: (outdated ? "OutdatedTokenResponse" : "TokenResponse"), ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        return try JSONDecoder().decode(TokenResponse.self, from: jsonData)
    }
}
