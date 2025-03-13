import Authentication
import GDSAnalytics
import Logging
import UIKit

@MainActor
final class WebAuthenticationService: AuthenticationService {
    private let session: LoginSession
    private let sessionManager: SessionManager
    private let analyticsService: OneLoginAnalyticsService
    
    init(sessionManager: SessionManager,
         session: LoginSession,
         analyticsService: OneLoginAnalyticsService) {
        self.sessionManager = sessionManager
        self.session = session
        self.analyticsService = analyticsService
    }
    
    func startWebSession() async throws {
        do {
            try await sessionManager.startSession(
                session,
                using: LoginSessionConfiguration.oneLoginSessionConfiguration
            )
        } catch let error as LoginError where error == .userCancelled {
            let userCancelEvent = ButtonEvent(textKey: "back")
            analyticsService.logEvent(userCancelEvent)
            throw error
        } catch let error as LoginError where error == .accessDenied {
            try sessionManager.clearAllSessionData()
            throw error
        }
    }
    
    func handleUniversalLink(_ url: URL) throws {
        try session.finalise(redirectURL: url)
    }
}
