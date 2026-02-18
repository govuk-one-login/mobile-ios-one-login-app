import Foundation
import GDSUtilities

public enum FirebaseAppCheckErrorType: String, GDSErrorKind {
    case unknown              = "unknown firebase app check service error"
    case network              = "network error in firebase app check service"
    case invalidConfiguration = "invalid configuration for firebase app check service"
    case keychainAccess       = "keychain access error in firebase app check service"
    case notSupported         = "firebase app check service not supported on this platform"
    case generic              = "generic firebase app check service error"
}

public enum ClientAssertionErrorType: String, GDSErrorKind {
    case invalidPublicKey          = "invalid client attestation public key"
}

public enum ProofOfPossessionErrorType: String, GDSErrorKind {
    case cantGenerateAttestationPublicKeyJWK           = "cant generate attestation public key JWK"
    case cantGenerateAttestationProofOfPossessionJWT   = "cant generate attestation proof of possession JWT"
    case cantGenerateDemonstratingProofOfPossessionJWT = "can't generate demonstrating public key dictionary JWT"
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
