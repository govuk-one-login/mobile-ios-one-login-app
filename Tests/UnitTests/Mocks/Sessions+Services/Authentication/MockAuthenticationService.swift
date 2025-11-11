import Authentication
import Foundation
@testable import OneLogin
import UIKit

final class MockAuthenticationService: AuthenticationService {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    func startWebSession() async throws {
        try await sessionManager.startAuthSession(
            MockLoginSession(window: UIWindow())) { _ in
                try await MockLoginSessionConfiguration.oneLoginSessionConfiguration()
            }
    }
    
    func handleUniversalLink(_ url: URL) throws {
        throw AuthenticationError.generic
    }
}
