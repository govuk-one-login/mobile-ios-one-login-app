import Foundation

final class RefreshTokenRepresentation: RefreshToken {
    var expiryDate: Date {
        refreshTokenPayload.exp.value
    }

    private var refreshTokenPayload: RefreshTokenPayload

    init(refreshToken: String,
         verifier: TokenVerifier = JWTVerifier()) throws {
        refreshTokenPayload = try verifier.extractPayload(refreshToken)
    }
}
