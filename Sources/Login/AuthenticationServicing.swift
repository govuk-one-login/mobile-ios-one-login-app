import Foundation

protocol AuthenticationService {
    func start() async throws
    @MainActor func handleUniversalLink(_ url: URL) throws
}
