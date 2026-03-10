import AppIntegrity
import Authentication
import CryptoService
import GDSAnalytics
import Logging
import SecureStore
import UIKit

@MainActor
final class WebAuthenticationService: AuthenticationService {
    private let session: LoginSession
    private let sessionManager: SessionManager
    private let analyticsService: OneLoginAnalyticsService
    
    init(
        sessionManager: SessionManager,
        session: LoginSession,
        analyticsService: OneLoginAnalyticsService
    ) {
        self.sessionManager = sessionManager
        self.session = session
        self.analyticsService = analyticsService
    }
    
    func startWebSession() async throws {
        do {
            try await sessionManager.startAuthSession(
                session,
                using: LoginSessionConfiguration.oneLoginSessionConfiguration
            )
        } catch let error as LoginError {
            switch error.reason {
            case .userCancelled:
                analyticsService.logEvent(ButtonEvent(textKey: "back"))
            case .authorizationAccessDenied:
                try await sessionManager.clearAllSessionData(presentSystemLogOut: false)
            case .invalidRedirectURL:
                if let underlyingReason = error.underlyingReason,
                   underlyingReason.starts(with: "access_denied") {
                    try await sessionManager.clearAllSessionData(presentSystemLogOut: false)
                    throw LoginError(
                        reason: .authorizationAccessDenied,
                        underlyingReason: underlyingReason
                    )
                } else {
                    analyticsService.logCrash(error)
                }
            default:
                analyticsService.logCrash(error)
            }
            throw error
        } catch {
            analyticsService.logCrash(error)
            throw error
        }
    }
    
    func handleUniversalLink(_ url: URL) throws {
        try session.finalise(redirectURL: url)
    }
}
