import Foundation

public protocol AppIntegrityProvider {
    func addIntegrityAssertions(to request: URLRequest) async throws -> URLRequest
}
