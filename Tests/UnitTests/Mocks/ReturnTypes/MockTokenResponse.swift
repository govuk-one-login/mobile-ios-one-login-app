import Authentication
import Foundation

final class MockTokenResponse {
    enum DecodeError: Error {
        case invalid
    }
    
    func getJSONData(outdated: Bool = false, withRefreshToken: Bool = true) throws -> TokenResponse {
        let bundleForTest = Bundle(for: type(of: self))
        let resource = outdated ? "OutdatedTokenResponse" : (withRefreshToken ? "TokenResponse" : "TokenResponseWithoutRefreshToken")
        guard let jsonPath = bundleForTest.path(forResource: resource, ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        return try JSONDecoder().decode(TokenResponse.self, from: jsonData)
    }
}
