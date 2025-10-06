import Foundation

public enum FirebaseAppCheckError: String {
    case unknown
    case network
    case invalidConfiguration
    case keychainAccess
    case notSupported
    case generic
}

public enum ClientAssertionError: String {
    case invalidPublicKey
    case invalidToken
    case serverError
    case cantDecodeClientAssertion
    case cantCreateAttestationPoP
}

public enum ProofOfPossessionError: String {
    case cantGeneratePublicKey
}

public struct AppIntegrityError<ErrorType: RawRepresentable>: Error, LocalizedError, Equatable where ErrorType.RawValue == String {
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
        lhs.errorType == rhs.errorType
    }
}
