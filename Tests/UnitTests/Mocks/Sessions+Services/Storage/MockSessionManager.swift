import Authentication
import Foundation
@testable import OneLogin
import SecureStore

final class MockSessionManager: SessionManager {
    var expiryDate: Date?
    var sessionExists: Bool
    var isSessionValid: Bool
    var isReturningUser: Bool
    
    var hasNotRemovedLocalAuth: Bool
    
    var user: (any OneLogin.User)?
    
    var isPersistentSessionIDMissing: Bool
    var tokenProvider: TokenHolder

    var didCallStartSession = false
    var didCallResumeSession = false
    var didCallEndCurrentSession = false
    var didCallClearAllSessionData = false

    var errorFromStartSession: Error?
    var errorFromResumeSession: Error?

    var localAuthentication: LocalAuthenticationManager = MockLocalAuthManager()

    init(expiryDate: Date? = nil,
         sessionExists: Bool = false,
         isSessionValid: Bool = false,
         isReturningUser: Bool = false,
         hasNotRemovedLocalAuth: Bool = true,
         user: (any User)? = nil,
         isPersistentSessionIDMissing: Bool = false,
         tokenProvider: TokenHolder = TokenHolder()) {
        self.expiryDate = expiryDate
        self.sessionExists = sessionExists
        self.isSessionValid = isSessionValid
        self.isReturningUser = isReturningUser
        self.hasNotRemovedLocalAuth = hasNotRemovedLocalAuth
        self.user = user
        self.isPersistentSessionIDMissing = isPersistentSessionIDMissing
        self.tokenProvider = tokenProvider
    }

    func startSession(using session: any LoginSession) async throws {
        defer {
            didCallStartSession = true
        }
        if let errorFromStartSession {
            throw errorFromStartSession
        }
    }

    func saveSession() async throws {

    }

    func resumeSession() throws {
        didCallResumeSession = true
        if let errorFromResumeSession {
            throw errorFromResumeSession
        }
    }
    
    func endCurrentSession() {
        didCallEndCurrentSession = true
    }
    
    func clearAllSessionData() {
        didCallClearAllSessionData = true
    }

    func setupSession(returningUser: Bool = true, expired: Bool = false) throws {
        let tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        tokenProvider.update(subjectToken: tokenResponse.accessToken)

        user = MockUser()
        isReturningUser = returningUser
        expiryDate = expired ? .distantPast : .distantFuture
        isSessionValid = !expired
    }
}
