import Foundation
import GDSUtilities

public enum RefreshTokenExchangeErrorKind: Int, GDSErrorKind {
    case accountIntervention = 1001
    case appIntegrityFailed = 1002
    case noInternet = 1003
    case reauthenticationRequired = 1004

    public var description: String {
        switch self {
        case .accountIntervention:
            return "there was an account intervention"
        case .appIntegrityFailed:
            return "app integrity failed for dPoP or client assertion"
        case .noInternet:
            return "no internet - enables offline user access"
        case .reauthenticationRequired:
            return "no refresh or id token or valid access token, user must reauthenticate"
        }
    }
}

public typealias RefreshTokenExchangeError = OneLoginGDSError<RefreshTokenExchangeErrorKind>

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
