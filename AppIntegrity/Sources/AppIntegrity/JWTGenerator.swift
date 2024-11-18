public protocol JWTGenerator {
    func generateJWT(header: [String: String], payload: [String: Any]) -> String
}
