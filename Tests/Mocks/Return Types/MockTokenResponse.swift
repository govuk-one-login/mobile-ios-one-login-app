import Authentication
import Foundation

class MockTokenResponse {
    enum DecodeError: Error {
        case invalid
    }
    
    func getJSONData() throws -> TokenResponse {
        let bundleDoingTest = Bundle(for: type(of: self ))
        guard let jsonPath = bundleDoingTest.path(forResource: "TokenResponse", ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        let tokenResponse = try JSONDecoder()
            .decode(TokenResponse.self, from: jsonData)
        return tokenResponse
    }
}
