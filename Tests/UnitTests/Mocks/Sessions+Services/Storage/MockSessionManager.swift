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
    
    var isAccessTokenValid: Bool
    var returnRefreshTokenIfValid: String?

    var persistentID: String?
    var user = CurrentValueSubject<(any OneLogin.User)?, Never>(nil)

    var tokenProvider: TokenHolder

    var didCallStartSession = false
    var didCallSaveSession = false
    var didCallSaveLoginTokens = false
    var didCallResumeSession = false
    var didCallEndCurrentSession = false
    var didCallClearAllSessionData = false
    var didCallClearAppForLogin = false

    var errorFromStartSession: Error?
    var errorFromSaveSession: Error?
    var errorFromSaveLoginTokens: Error?
    var errorFromResumeSession: Error?
    var errorFromClearAllSessionData: Error?
    var errorFromClearAppForLogin: Error?

    var localAuthentication: LocalAuthManaging = MockLocalAuthManager()

    init(expiryDate: Date? = nil,
         isEnrolling: Bool = false,
         isReturningUser: Bool = false,
         isAccessTokenValid: Bool = false,
         returnRefreshTokenIfValid: String? = nil,
         sessionState: SessionState = .nonePresent,
         tokenProvider: TokenHolder = TokenHolder()) {
        self.expiryDate = expiryDate
        self.isEnrolling = isEnrolling
        self.isReturningUser = isReturningUser
        self.isAccessTokenValid = isAccessTokenValid
        self.returnRefreshTokenIfValid = returnRefreshTokenIfValid
        self.tokenProvider = tokenProvider
        self.sessionState = sessionState
    }
    
    func getIDToken() throws -> String? {
        return "idToken"
    }

    func startAuthSession(
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

    func saveAuthSession() throws {
        defer {
            didCallSaveSession = true
        }
        if let errorFromSaveSession {
            throw errorFromSaveSession
        }
    }
    
    func saveLoginTokens(tokenResponse: TokenResponse, idToken: String?) throws {
        defer {
            didCallSaveLoginTokens = true
        }
        if let errorFromSaveLoginTokens {
            throw errorFromSaveLoginTokens
        }
    }

    func resumeSession(tokenExchangeManager: TokenExchangeManaging) throws {
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
    
    func clearAllSessionData(presentSystemLogOut: Bool = true) throws {
        defer {
            didCallClearAllSessionData = true
        }
        if let errorFromClearAllSessionData {
            throw errorFromClearAllSessionData
        }
        if presentSystemLogOut {
            NotificationCenter.default.post(name: .systemLogUserOut)
        } else {
            NotificationCenter.default.post(name: .userDidLogout)
        }
    }
    
    func clearAppForLogin() async throws {
        defer {
            didCallClearAppForLogin = true
        }
        if let errorFromClearAppForLogin {
            throw errorFromClearAppForLogin
        }
    }
    
    func setupSession(returningUser: Bool = true, expired: Bool = false) throws {
        let tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        tokenProvider.update(subjectToken: tokenResponse.accessToken)

        user.send(MockUser())
        isReturningUser = returningUser
        expiryDate = expired ? .distantPast : .distantFuture
    }
}
