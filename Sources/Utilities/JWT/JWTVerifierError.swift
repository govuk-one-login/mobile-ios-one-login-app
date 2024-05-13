import Foundation

enum JWTVerifierError: LocalizedError {
    case unableToFetchJWKs
    case invalidKID
    case invalidJWTFormat
}
