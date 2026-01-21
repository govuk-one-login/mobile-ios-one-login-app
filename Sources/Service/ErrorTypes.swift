import Foundation

enum RefreshTokenExchangeError: Error {
    case accountIntervention
    case appIntegrityRetryError
    case noInternet
    case reauthenticationRequired
}

struct ServerErrorResponse: Decodable {
    let error: GrantType?
    let errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

public enum GrantType: String, Decodable {
    case invalidGrant = "invalid_grant"
    case invalidTarget = "invalid_target"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        self = GrantType(rawValue: rawValue) ?? .unknown
    }
}
