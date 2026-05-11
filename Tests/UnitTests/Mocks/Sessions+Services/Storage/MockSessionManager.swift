import AppIntegrity
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
    
    var validTokensForRefreshExchange: (idToken: String, refreshToken: String)?

    var persistentID: String?
    var walletStoreID: String?
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
         validTokensForRefreshExchange: (String, String)? = nil,
         sessionState: SessionState = .nonePresent,
         tokenProvider: TokenHolder = TokenHolder()) {
        self.expiryDate = expiryDate
        self.isEnrolling = isEnrolling
        self.isReturningUser = isReturningUser
        self.validTokensForRefreshExchange = validTokensForRefreshExchange
        self.tokenProvider = tokenProvider
        self.sessionState = sessionState
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
    
    func saveLoginTokens(
        idToken: String?,
        refreshToken: String?,
        accessToken: String?,
        accessTokenExpiry: Date?
    ) throws {
        defer {
            didCallSaveLoginTokens = true
        }
        if let errorFromSaveLoginTokens {
            throw errorFromSaveLoginTokens
        }
    }

    func resumeSession(
        tokenExchangeManager: TokenExchangeManaging,
        appIntegrityProvider: AppIntegrityProvider
    ) throws {
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
        tokenProvider.update(accessToken: tokenResponse.accessToken, accessTokenExpiry: Date())

        user.send(MockUser())
        isReturningUser = returningUser
        expiryDate = expired ? .distantPast : .distantFuture
    }
}

class MockSessionManagerExpectation: SessionManager {
    var sessionState: SessionState {
        sessionManager.sessionState
    }

    var expiryDate: Date? {
        sessionManager.expiryDate
    }
    var isEnrolling: Bool {
        get {
            sessionManager.isEnrolling
        }
        set {
            sessionManager.isEnrolling = newValue
        }
    }
    
    var isReturningUser: Bool {
        sessionManager.isReturningUser
    }
    
    var validTokensForRefreshExchange: (idToken: String, refreshToken: String)?

    var persistentID: String? {
        sessionManager.persistentID
    }
    
    var walletStoreID: String? {
        sessionManager.walletStoreID
    }

    var user: CurrentValueSubject<(any OneLogin.User)?, Never> {
        sessionManager.user
    }
    
    var tokenProvider: TokenHolder {
        sessionManager.tokenProvider
    }
    
    typealias DidStartAuthSession = (LoginSession, @Sendable (String?) async throws -> LoginSessionConfiguration) -> Void
    typealias DidSaveAuthSession = () -> Void
    typealias DidResumeSession = (TokenExchangeManaging, AppIntegrityProvider) -> Void
    
    var didStartAuthSessionAsFunction: DidStartAuthSession
    var didSaveAuthSessionAsFunction: DidSaveAuthSession
    var didResumeSessionAsFunction: DidResumeSession

    var localAuthentication: LocalAuthManaging {
        sessionManager.localAuthentication
    }
    
    let sessionManager: MockSessionManager
    
    init(sessionManager: MockSessionManager = MockSessionManager(),
         didStartAuthSessionAsFunction: @escaping DidStartAuthSession = {_, _ in },
         didSaveAuthSessionAsFunction: @escaping DidSaveAuthSession = { },
         didResumeSessionAsFunction: @escaping DidResumeSession = {_, _ in}) {
        self.sessionManager = sessionManager
        self.didStartAuthSessionAsFunction = didStartAuthSessionAsFunction
        self.didSaveAuthSessionAsFunction = didSaveAuthSessionAsFunction
        self.didResumeSessionAsFunction = didResumeSessionAsFunction
    }
    
    func startAuthSession(
        _ session: any LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) throws {
        defer {
            self.didStartAuthSessionAsFunction(session, configuration)
        }
        
        try sessionManager.startAuthSession(session, using: configuration)
    }
    
    func saveAuthSession() throws {
        defer {
            self.didSaveAuthSessionAsFunction()
        }
    
        try sessionManager.saveAuthSession()
    }
    
    func saveLoginTokens(idToken: String?, refreshToken: String?, accessToken: String?, accessTokenExpiry: Date?) throws {
        try sessionManager.saveLoginTokens(idToken: idToken, refreshToken: refreshToken, accessToken: accessToken, accessTokenExpiry: accessTokenExpiry)
    }
    
    func resumeSession(tokenExchangeManager: TokenExchangeManaging, appIntegrityProvider: AppIntegrityProvider) async throws {
        defer {
            self.didResumeSessionAsFunction(tokenExchangeManager, appIntegrityProvider)
        }
        try sessionManager.resumeSession(tokenExchangeManager: tokenExchangeManager, appIntegrityProvider: appIntegrityProvider)
    }
    
    func endCurrentSession() {
        sessionManager.endCurrentSession()
    }
    
    func clearAllSessionData(presentSystemLogOut: Bool) async throws {
        try sessionManager.clearAllSessionData(presentSystemLogOut: presentSystemLogOut)
    }
    
    func clearAppForLogin() async throws {
        try await sessionManager.clearAppForLogin()
    }
}
