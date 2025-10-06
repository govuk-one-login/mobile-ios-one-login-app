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
        } catch let error as LoginErrorV2 where error.reason == .userCancelled {
            let userCancelEvent = ButtonEvent(textKey: "back")
            analyticsService.logEvent(userCancelEvent)
            throw error
        } catch let error as LoginErrorV2 where error.reason == .authorizationAccessDenied {
            try await sessionManager.clearAllSessionData(restartLoginFlow: true)
            throw error
        } catch let error as AppIntegritySigningError {
            analyticsService.logCrash(error)
            throw error
        } catch let error as AppIntegrityError<FirebaseAppCheckError> {
            analyticsService.logCrash(error)
            throw error
        } catch let error as AppIntegrityError<ClientAssertionError> {
            analyticsService.logCrash(error)
            throw error
        } catch let error as AppIntegrityError<ProofOfPossessionError> {
            analyticsService.logCrash(error)
            throw error
        } catch let error as SecureStoreError {
            analyticsService.logCrash(error)
            throw error
        }
    }
    
    func handleUniversalLink(_ url: URL) throws {
        try session.finalise(redirectURL: url)
    }
}
