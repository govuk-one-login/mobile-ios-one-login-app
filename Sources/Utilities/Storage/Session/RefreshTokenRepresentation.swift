import Foundation

final class RefreshTokenRepresentation: RefreshToken {
    var expiryDate: String {
        refreshTokenPayload.exp.value.timeIntervalSince1970.description
    }

    private var refreshTokenPayload: RefreshTokenPayload

    init(refreshToken: String,
         verifier: TokenVerifier = JWTVerifier()) throws {
        refreshTokenPayload = try verifier.extractPayload(refreshToken)
    }
}
