import Authentication
import Combine
import Foundation
import LocalAuthenticationWrapper
import SecureStore

final class PersistentSessionManager: SessionManager {
    private let accessControlEncryptedStore: SecureStorable
    private let encryptedStore: SecureStorable
    private let storeKeyService: TokenStore
    private let unprotectedStore: DefaultsStoring
    
    let localAuthentication: LocalAuthManaging
    let tokenProvider: TokenHolder
    
    var isEnrolling: Bool = false
    
    private var tokenResponse: TokenResponse?
    private var sessionBoundData = [SessionBoundData]()
    
    let user = CurrentValueSubject<(any User)?, Never>(nil)
    
    convenience init(
        accessControlEncryptedStore: SecureStorable,
        encryptedStore: SecureStorable
    ) {
        self.init(
            accessControlEncryptedStore: accessControlEncryptedStore,
            encryptedStore: encryptedStore,
            unprotectedStore: UserDefaults.standard,
            localAuthentication: LocalAuthenticationWrapper(localAuthStrings: .oneLogin)
        )
    }
    
    init(
        accessControlEncryptedStore: SecureStorable,
        encryptedStore: SecureStorable,
        unprotectedStore: DefaultsStoring,
        localAuthentication: LocalAuthManaging
    ) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.storeKeyService = SecureTokenStore(
            accessControlEncryptedStore: accessControlEncryptedStore
        )
        self.unprotectedStore = unprotectedStore
        self.localAuthentication = localAuthentication
        
        self.tokenProvider = TokenHolder()
    }
    
    var sessionState: SessionState {
        if isValidEnrolment {
            return .enrolling
        } else if isOneTimeUser {
            return .oneTime
        } else {
            guard expiryDate != nil else {
                return .nonePresent
            }
            
            guard isSessionValid else {
                return .expired
            }
            
            return .saved
        }
    }
    
    private var isValidEnrolment: Bool {
        guard let tokenResponse else {
            return false
        }
        return isEnrolling && tokenResponse.expiryDate > .now
    }
    
    private var isOneTimeUser: Bool {
        tokenProvider.subjectToken != nil && !isReturningUser
    }
    
    var expiryDate: Date? {
        (try? encryptedStore.readDate(id: OLString.refreshTokenExpiry))
        ?? unprotectedStore.value(forKey: OLString.accessTokenExpiry) as? Date
    }
    
    var isSessionValid: Bool {
        guard let expiryDate else {
            return false
        }
        // Fifteen second buffer for access token expiry when user comes in to perform an ID Check
        return expiryDate - 15 > .now
    }
    
    var isReturningUser: Bool {
        unprotectedStore.bool(forKey: OLString.returningUser)
    }
    
    var persistentID: String? {
        try? encryptedStore.readItem(itemName: OLString.persistentSessionID)
    }
    
    private var hasNotRemovedLocalAuth: Bool {
        (try? localAuthentication.canUseAnyLocalAuth) ?? false && isReturningUser
    }
    
    func startSession(
        _ session: any LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) async throws {
        guard !isReturningUser || persistentID != nil else {
            // I am a returning user
            // but cannot reauthenticate because I don't have a persistent session ID
            //
            // I need to delete my session & Wallet data before I can login
            do {
                try await clearAllSessionData(restartLoginFlow: true)
            } catch {
                throw PersistentSessionError.cannotDeleteData(error)
            }
            
            throw PersistentSessionError.sessionMismatch
        }
        
        let response = try await session
            .performLoginFlow(configuration: configuration(persistentID))
        tokenResponse = response
        
        // update curent state
        tokenProvider.update(subjectToken: response.accessToken)
        // TODO: DCMAW-8570 This should be considered non-optional once tokenID work is completed on BE
        if let idToken = response.idToken {
            user.send(try IDTokenUserRepresentation(idToken: idToken))
        } else {
            user.send(nil)
        }
        
        guard isReturningUser else {
            // user has not yet enroled in local authentication
            // so tokens should not be saved !
            return
        }
        
        try saveSession()
        
        NotificationCenter.default.post(name: .enrolmentComplete)
    }
    
    func saveSession() throws {
        guard let tokenResponse else {
            assertionFailure("Could not save session as token response was not set")
            return
        }
        
        if let persistentID = user.value?.persistentID {
            try encryptedStore.saveItem(
                item: persistentID,
                itemName: OLString.persistentSessionID
            )
        } else {
            encryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        }
        
        if let refreshToken = tokenResponse.refreshToken {
            try encryptedStore.saveDate(
                id: OLString.refreshTokenExpiry,
                try RefreshTokenRepresentation(refreshToken: refreshToken).expiryDate
            )
        }
        
        let tokens = StoredTokens(
            idToken: tokenResponse.idToken,
            refreshToken: tokenResponse.refreshToken,
            accessToken: tokenResponse.accessToken
        )
        
        try storeKeyService.save(tokens: tokens)
        
        unprotectedStore.set(
            tokenResponse.expiryDate,
            forKey: OLString.accessTokenExpiry
        )
        
        unprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
    }
    
    func resumeSession() throws {
        guard hasNotRemovedLocalAuth else {
            throw PersistentSessionError.userRemovedLocalAuth
        }
        
        let keys = try storeKeyService.fetch()
                
        if let idToken = keys.idToken {
            user.send(try IDTokenUserRepresentation(idToken: idToken))
        } else {
            user.send(nil)
        }
        
        tokenProvider.update(subjectToken: keys.accessToken)
    }
    
    func endCurrentSession() {
        storeKeyService.deleteTokens()
        
        tokenProvider.clear()
        tokenResponse = nil
        user.send(nil)
    }
    
    func clearAllSessionData(restartLoginFlow: Bool) async throws {
        for each in sessionBoundData {
            try await each.clearSessionData()
        }
        
        endCurrentSession()
        
        if restartLoginFlow {
            NotificationCenter.default.post(
                name: .systemLogUserOut
            )
        }
    }
    
    func registerSessionBoundData(_ data: [SessionBoundData]) {
        sessionBoundData = data
    }
}

enum PersistentSessionError: Error, Equatable {
    case noSessionExists
    case userRemovedLocalAuth
    case sessionMismatch
    case cannotDeleteData(Error)
    
    static func == (lhs: PersistentSessionError, rhs: PersistentSessionError) -> Bool {
        switch (lhs, rhs) {
        case (.noSessionExists, .noSessionExists),
            (.userRemovedLocalAuth, .userRemovedLocalAuth),
            (.sessionMismatch, .sessionMismatch),
            (.cannotDeleteData, .cannotDeleteData):
            true
        default:
            false
        }
    }
}

protocol SessionBoundData {
    func clearSessionData() async throws
}
