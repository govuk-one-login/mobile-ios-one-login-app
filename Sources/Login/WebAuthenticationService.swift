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
        try await self.startWebSession(appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck())
    }
    
    func startWebSession(appIntegrityProvider: @autoclosure @escaping () throws(AppIntegritySigningError) -> AppIntegrityProvider) async throws {
        do {
            try await sessionManager.startAuthSession(
                session,
                using: { persistentSessionID in
                    try await LoginSessionConfiguration.oneLoginSessionConfiguration(
                        persistentSessionID: persistentSessionID,
                        appIntegrityProvider: appIntegrityProvider
                        )
                }
            )
        } catch let error as LoginError {
            switch error.kind {
            case .userCancelled:
                analyticsService.logEvent(ButtonEvent(textKey: "back"))
            case .authorizationAccessDenied:
                try await sessionManager.clearAllSessionData(presentSystemLogOut: false)
            case .invalidRedirectURL:
                if let underlyingReason = error.reason,
                   underlyingReason.starts(with: "access_denied") {
                    try await sessionManager.clearAllSessionData(presentSystemLogOut: false)
                    throw LoginError(
                        .authorizationAccessDenied,
                        reason: underlyingReason
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
