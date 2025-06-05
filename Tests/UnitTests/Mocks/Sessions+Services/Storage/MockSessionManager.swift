import Authentication
import Combine
import Foundation
import LocalAuthenticationWrapper
@testable import OneLogin

final class MockSessionManager: SessionManager {
    var sessionState: SessionState

    var expiryDate: Date?
    var isEnrolling: Bool
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
    var errorFromSaveSession: Error?

    var localAuthentication: LocalAuthManaging = MockLocalAuthManager()

    init(expiryDate: Date? = nil,
         isEnrolling: Bool = false,
         isReturningUser: Bool = false,
         sessionState: SessionState = .nonePresent,
         tokenProvider: TokenHolder = TokenHolder()) {
        self.expiryDate = expiryDate
        self.isEnrolling = isEnrolling
        self.isReturningUser = isReturningUser
        self.tokenProvider = tokenProvider
        self.sessionState = sessionState
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

    func saveSession() throws {
        defer {
            didCallSaveSession = true
        }
        if let errorFromSaveSession {
            throw errorFromSaveSession
        }
    }

    func resumeSession() throws {
        defer {
            didCallResumeSession = true
        }
        if let errorFromResumeSession {
            throw errorFromResumeSession
        }
    }
    
    func endCurrentSession() {
        didCallEndCurrentSession = true
    }
    
    func clearAllSessionData() throws {
        defer {
            didCallClearAllSessionData = true
        }
        if let errorFromClearAllSessionData {
            throw errorFromClearAllSessionData
        }
        NotificationCenter.default.post(name: .didLogout)
    }

    func setupSession(returningUser: Bool = true, expired: Bool = false) throws {
        let tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        tokenProvider.update(subjectToken: tokenResponse.accessToken)

        user.send(MockUser())
        isReturningUser = returningUser
        expiryDate = expired ? .distantPast : .distantFuture
    }
}
