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
