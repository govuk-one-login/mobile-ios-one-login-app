import Foundation
import GDSUtilities


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

enum RefreshTokenExchangeErrorType: Int, GDSErrorKind {
    case accountIntervention = 1001
    case appIntegrityFailed = 1002
    case noInternet = 1003
    case reauthenticationRequired = 1004

    public var description: String {
        switch self {
        case .accountIntervention:
            ""
        case .appIntegrityFailed:
            ""
        case .noInternet:
            ""
        case .reauthenticationRequired:
            ""
        }
    }
}

struct RefreshTokenExchangeError<Kind: GDSErrorKind>: GDSError {
    let kind: Kind
    let reason: String?
    let endpoint: String?
    let statusCode: Int?
    let file: String
    let function: String
    let line: Int
    let resolvable: Bool
    let originalError: (any Error)?
    let additionalParameters: [String: any Sendable]

    init(
        _ kind: Kind,
        reason: String? = nil,
        endpoint: String? = nil,
        statusCode: Int? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        resolvable: Bool = false,
        originalError: (any Error)? = nil,
        additionalParameters: [String: any Sendable] = [:]
    ) {
        self.kind = kind
        self.reason = reason
        self.endpoint = endpoint
        self.statusCode = statusCode
        self.file = file
        self.function = function
        self.line = line
        self.resolvable = resolvable
        self.originalError = originalError
        self.additionalParameters = additionalParameters
    }
}
