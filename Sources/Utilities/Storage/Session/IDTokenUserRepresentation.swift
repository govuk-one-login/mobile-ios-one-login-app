final class IDTokenUserRepresentation: User {
    var persistentID: String {
        idTokenPayload.persistentId
    }
    
    var walletStoreID: String {
        idTokenPayload.walletStoreId
    }

    var email: String {
        idTokenPayload.email
    }

    private var idTokenPayload: IdTokenPayload

    init(idToken: String,
         verifier: TokenVerifier = JWTVerifier()) throws {
        idTokenPayload = try verifier.extractPayload(idToken)
    }
    
    init(verify idToken: String,
         verifier: TokenVerifier = JWTVerifier(),
        ) async throws {
        idTokenPayload = try await verifier.verifyToken(idToken)
    }
}
