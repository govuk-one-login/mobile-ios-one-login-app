import Foundation

public enum FirebaseAppCheckErrorType: String {
    case unknown              = "unknown firebase app check service error"
    case network              = "network error in firebase app check service"
    case invalidConfiguration = "invalid configuration for firebase app check service"
    case keychainAccess       = "keychain access error in firebase app check service"
    case notSupported         = "firebase app check service not supported on this platform"
    case generic              = "generic firebase app check service error"
}

public enum ClientAssertionErrorType: String {
    case invalidPublicKey                       = "invalid client attestation public key"
    case invalidToken                           = "invalid firebase app check token"
    case serverError                            = "server error"
    case cantDecodeClientAssertion              = "cant decode client attestation"
    case cantCreateAttestationProofOfPossession = "cant create attestation proof of possession"
}

public enum ProofOfPossessionErrorType: String {
    case cantGeneratePublicKey = "cant generate proof of possession public key"
}

public enum DPoPErrorType: String {
    case cantCreateDPoP = "can't create DPoP"
}

public struct AppIntegrityError<ErrorType: RawRepresentable>: Error, LocalizedError, CustomNSError, Equatable where ErrorType.RawValue == String {
    public let errorType: ErrorType
    public let errorDescription: String?
    public let failureReason: String?
    
    public init(
        _ errorType: ErrorType,
        errorDescription: String
    ) {
        self.errorType = errorType
        self.errorDescription = errorDescription
        self.failureReason = errorType.rawValue
    }
    
    public static func == (lhs: AppIntegrityError<ErrorType>, rhs: AppIntegrityError<ErrorType>) -> Bool {
        lhs.errorType == rhs.errorType && lhs.errorDescription == rhs.errorDescription
    }
}

public typealias FirebaseAppCheckError = AppIntegrityError<FirebaseAppCheckErrorType>
public typealias ClientAssertionError = AppIntegrityError<ClientAssertionErrorType>
public typealias ProofOfPossessionError = AppIntegrityError<ProofOfPossessionErrorType>
public typealias DPoPError = AppIntegrityError<DPoPErrorType>
