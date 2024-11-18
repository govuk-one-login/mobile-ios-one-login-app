public protocol JWTGenerator {
    func generateJWT(header: [String: Any], payload: [String: Any]) -> String
}
