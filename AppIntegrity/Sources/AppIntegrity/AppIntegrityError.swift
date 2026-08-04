import Foundation
import GDSUtilities

public enum FirebaseAppCheckErrorType: Int, GDSErrorKind {
    case unknown = 1000
    case network = 1001
    case invalidConfiguration = 1002
    case keychainAccess = 1003
    case notSupported = 1004
    case generic = 1005

    public var description: String {
        switch self {
        case .unknown:
            return "unknown firebase app check service error"
        case .network:
            return "network error in firebase app check service"
        case .invalidConfiguration:
            return "invalid configuration for firebase app check service"
        case .keychainAccess:
            return "keychain access error in firebase app check service"
        case .notSupported:
            return "firebase app check service not supported on this platform"
        case .generic:
            return "generic firebase app check service error"
        }
    }
}

public enum ClientAssertionErrorType: Int, GDSErrorKind {
    case invalidPublicKey = 1001
    case invalidToken = 1002
    
    // MARK: ServerError(400)
    case serverError = 2001
    
    // MARK: ServerError(500)
    case cantDecodeClientAssertion = 3001

    public var description: String {
        switch self {
        case .invalidPublicKey:
            return "invalid client attestation public key"
        case .invalidToken:
            return "invalid firebase app check token"
        case .serverError:
            return "server error"
        case .cantDecodeClientAssertion:
            return "cant decode client attestation"
        }
    }
}

public enum ProofOfPossessionErrorType: Int, GDSErrorKind {
    case cantGenerateDemonstratingProofOfPossessionJWT = 1001
    case cantGenerateAttestationPublicKeyJWK = 1002
    case cantGenerateAttestationProofOfPossessionJWT = 1003

    public var description: String {
        switch self {
        case .cantGenerateAttestationPublicKeyJWK:
            return "cant generate attestation public key JWK"
        case .cantGenerateAttestationProofOfPossessionJWT:
            return "cant generate attestation proof of possession JWT"
        case .cantGenerateDemonstratingProofOfPossessionJWT:
            return "can't generate demonstrating public key dictionary JWT"
        }
    }
}

public struct AppIntegrityError<Kind: GDSErrorKind>: GDSError {
    public let kind: Kind
    public let reason: String?
    public let endpoint: String?
    public let statusCode: Int?
    public let file: String
    public let function: String
    public let line: Int
    public let resolvable: Bool
    public let originalError: (any Error)?
    public let additionalParameters: [String: any Sendable]

    public init(
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

public typealias FirebaseAppCheckError = AppIntegrityError<FirebaseAppCheckErrorType>
public typealias ClientAssertionError = AppIntegrityError<ClientAssertionErrorType>
public typealias ProofOfPossessionError = AppIntegrityError<ProofOfPossessionErrorType>
