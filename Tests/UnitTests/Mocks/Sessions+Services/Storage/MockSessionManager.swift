import Authentication
import Foundation
@testable import OneLogin
import SecureStore

final class MockSessionManager: SessionManager {
    var expiryDate: Date?
    var sessionExists: Bool
    var isSessionValid: Bool
    var isReturningUser: Bool
    
    var user: (any OneLogin.User)?
    
    var isPersistentSessionIDMissing: Bool
    var tokenProvider: TokenHolder

    var didCallEndCurrentSession: Bool = false
    var didCallClearAllSessionData: Bool = false

    var shouldThrowResumeError: Error?

    var didCallStartSession: Bool = false

    init(expiryDate: Date? = nil,
         sessionExists: Bool = false,
         isSessionValid: Bool = false,
         isReturningUser: Bool = false,
         user: (any OneLogin.User)? = nil,
         isPersistentSessionIDMissing: Bool = false,
         tokenProvider: TokenHolder = TokenHolder()) {
        self.expiryDate = expiryDate
        self.sessionExists = sessionExists
        self.isSessionValid = isSessionValid
        self.isReturningUser = isReturningUser
        self.user = user
        self.isPersistentSessionIDMissing = isPersistentSessionIDMissing
        self.tokenProvider = tokenProvider
    }

    func startSession(using session: any LoginSession) async throws {
        didCallStartSession = true
    }
    
    func resumeSession() throws {
        if let shouldThrowResumeError {
            throw shouldThrowResumeError
        }
    }
    
    func endCurrentSession() {
        didCallEndCurrentSession = true
    }
    
    func clearAllSessionData() {
        didCallClearAllSessionData = true
    }

    func setupSession(isReturningUser: Bool = true, expired: Bool = false) throws {
        let tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        tokenProvider.update(tokens: tokenResponse)

        user = MockUser()
        self.isReturningUser = isReturningUser
        expiryDate = .distantFuture
    }
}
