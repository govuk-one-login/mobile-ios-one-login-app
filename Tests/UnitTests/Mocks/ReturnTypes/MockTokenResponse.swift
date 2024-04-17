import Authentication
import Foundation

class MockTokenResponse {
    enum DecodeError: Error {
        case invalid
    }
    
    func getJSONData() throws -> TokenResponse {
        let bundleDoingTest = Bundle(for: type(of: self))
        guard let jsonPath = bundleDoingTest.path(forResource: "TokenResponse", ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let tokenResponse = try decoder.decode(TokenResponse.self, from: jsonData)
        return tokenResponse
    }
    
    func getOutdatedJSONData() throws -> TokenResponse {
        let bundleDoingTest = Bundle(for: type(of: self))
        guard let jsonPath = bundleDoingTest.path(forResource: "OutdatedTokenResponse", ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let tokenResponse = try decoder.decode(TokenResponse.self, from: jsonData)
        return tokenResponse
    }
}
