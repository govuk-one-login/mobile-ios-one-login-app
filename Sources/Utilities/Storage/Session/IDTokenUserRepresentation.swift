final class IDTokenUserRepresentation: User {
    var persistentID: String {
        idTokenPayload.persistentId
    }

    var email: String {
        idTokenPayload.email
    }

    private var idTokenPayload: IdTokenPayload

    init(idToken: String,
         verifier: TokenVerifier = JWTVerifier()) throws {
        idTokenPayload = try verifier.extractPayload(idToken)
    }
}

final class RefreshTokenRepresentation: RefreshToken {
    var expiry: Int {
        Int(refreshTokenPayload.exp.value.timeIntervalSince1970)
    }

    private var refreshTokenPayload: RefreshTokenPayload

    init(refreshToken: String,
         verifier: TokenVerifier = JWTVerifier()) throws {
        refreshTokenPayload = try verifier.extractPayload(refreshToken)
    }
}
