import Authentication
import Foundation

class MockTokenResponse {
    enum DecodeError: Error {
        case invalid
    }
    
    func getJSONData(outdated: Bool = false) throws -> TokenResponse {
        let bundleForTest = Bundle(for: type(of: self))
        guard let jsonPath = bundleForTest.path(forResource: (outdated ? "OutdatedTokenResponse" : "TokenResponse"), ofType: "json"),
              let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            throw DecodeError.invalid
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom {
            let container = try $0.singleValueContainer()
            let dateDouble = try container.decode(Double.self)
            return Date(timeIntervalSinceNow: dateDouble)
        }
        return try decoder.decode(TokenResponse.self, from: jsonData)
    }
}
