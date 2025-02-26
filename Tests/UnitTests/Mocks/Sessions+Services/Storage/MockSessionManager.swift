import Authentication
import Combine
import Foundation
@testable import OneLogin
import SecureStore

final class MockSessionManager: SessionManager {
    var expiryDate: Date?
    var sessionExists: Bool
    var isSessionValid: Bool
    var isOneTimeUser: Bool
    var isReturningUser: Bool

    var user = CurrentValueSubject<(any OneLogin.User)?, Never>(nil)

    var tokenProvider: TokenHolder

    var didCallStartSession = false
    var didCallSaveSession = false
    var didCallResumeSession = false
    var didCallEndCurrentSession = false
    var didCallClearAllSessionData = false

    var errorFromStartSession: Error?
    var errorFromResumeSession: Error?
    var errorFromClearAllSessionData: Error?

    var localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck = MockLocalAuthManager()

    init(expiryDate: Date? = nil,
         sessionExists: Bool = false,
         isSessionValid: Bool = false,
         isReturningUser: Bool = false,
         isOneTimeUser: Bool = false,
         tokenProvider: TokenHolder = TokenHolder()) {
        self.expiryDate = expiryDate
        self.sessionExists = sessionExists
        self.isSessionValid = isSessionValid
        self.isReturningUser = isReturningUser
        self.tokenProvider = tokenProvider
        self.isOneTimeUser = isOneTimeUser
    }

    func startSession(
        _ session: any LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) throws {
        defer {
            didCallStartSession = true
        }
        if let errorFromStartSession {
            throw errorFromStartSession
        }
    }

    func saveSession() async throws {
        didCallSaveSession = true
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
    
    func clearAllSessionData() throws {
        NotificationCenter.default.post(name: .didLogout)
        didCallClearAllSessionData = true
        if let errorFromClearAllSessionData {
            throw errorFromClearAllSessionData
        }
    }

    func setupSession(returningUser: Bool = true, expired: Bool = false) throws {
        let tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        tokenProvider.update(subjectToken: tokenResponse.accessToken)

        user.send(MockUser())
        isReturningUser = returningUser
        expiryDate = expired ? .distantPast : .distantFuture
        isSessionValid = !expired
    }
}
