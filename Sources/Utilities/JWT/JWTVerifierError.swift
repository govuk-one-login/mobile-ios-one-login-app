import Foundation

enum JWTVerifierError: String, Error {
    case unableToFetchJWKs = "Unable to fetch JWKs"
    case invalidKID = "Invalid or missing KID"
    case invalidJWTFormat = "Invalid JWT format"
}

extension JWTVerifierError: LocalizedError {
    public var errorDescription: String? {
        NSLocalizedString(rawValue, comment: "")
    }
}
