import Foundation

protocol AuthenticationService {
    func startWebSession() async throws
    @MainActor func handleUniversalLink(_ url: URL) throws
}
