import Authentication
import Foundation

class MockTokenResponse {
    enum DecodeError: Error {
        case invalid
    }
    
    func getJSONData(outdated: Bool = false) throws -> TokenResponse {
        let bundleDoingTest = Bundle(for: type(of: self))
        guard let jsonPath = bundleDoingTest.path(forResource: "\(outdated ? "Outdated" : "")TokenResponse", ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateInt = try container.decode(Double.self)
            return Date(timeIntervalSinceNow: dateInt)
        }
        let tokenResponse = try decoder.decode(TokenResponse.self, from: jsonData)
        return tokenResponse
    }
}
