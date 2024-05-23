import Foundation

protocol TokenVerifier {
    func verifyToken(_ token: String) async throws -> IdTokenPayload?
    func extractPayload(_ token: String) throws -> IdTokenPayload?
}
