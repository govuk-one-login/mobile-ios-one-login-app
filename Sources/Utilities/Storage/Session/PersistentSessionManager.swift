import Authentication
import Combine
import Foundation
import LocalAuthenticationWrapper

final class PersistentSessionManager: SessionManager {
    private let secureStoreManager: SecureStoreManager
    private let storeKeyService: TokenStore
    private let unprotectedStore: DefaultsStorable
    let localAuthentication: LocalAuthManaging
    
    let tokenProvider: TokenHolder
    private var tokenResponse: TokenResponse?
    
    private var sessionBoundData = [SessionBoundData]()
    
    let user = CurrentValueSubject<(any User)?, Never>(nil)
    
    convenience init(secureStoreManager: SecureStoreManager) {
        self.init(
            secureStoreManager: secureStoreManager,
            unprotectedStore: UserDefaults.standard,
            localAuthentication: LocalAuthenticationWrapper(localAuthStrings: .oneLogin)
        )
    }
    
    init(secureStoreManager: SecureStoreManager,
         unprotectedStore: DefaultsStorable,
         localAuthentication: LocalAuthManaging) {
        self.secureStoreManager = secureStoreManager
        self.storeKeyService = SecureTokenStore(accessControlEncryptedStore: secureStoreManager.accessControlEncryptedStore)
        self.unprotectedStore = unprotectedStore
        self.localAuthentication = localAuthentication
        
        self.tokenProvider = TokenHolder()
    }
    
    private var persistentID: String? {
        try? secureStoreManager.encryptedStore.readItem(itemName: OLString.persistentSessionID)
    }
    
    var expiryDate: Date? {
        unprotectedStore.value(forKey: OLString.accessTokenExpiry) as? Date
    }
    
    var sessionExists: Bool {
        tokenProvider.subjectToken != nil
    }
    
    var isSessionValid: Bool {
        guard let expiryDate else {
            return false
        }
        return expiryDate > .now
    }
    
    var isReturningUser: Bool {
        unprotectedStore.value(forKey: OLString.returningUser) as? Bool
        ?? false
    }
    
    var isOneTimeUser: Bool {
        sessionExists && !isReturningUser
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
                try await clearAllSessionData()
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
            try user.send(IDTokenUserRepresentation(idToken: idToken))
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
        
        let tokens = StoredTokens(idToken: tokenResponse.idToken,
                                  accessToken: tokenResponse.accessToken)
        
        try storeKeyService.save(tokens: tokens)
        
        if let persistentID = user.value?.persistentID {
            try secureStoreManager.encryptedStore.saveItem(item: persistentID,
                                                           itemName: OLString.persistentSessionID)
        } else {
            secureStoreManager.encryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        }
        
        unprotectedStore.set(tokenResponse.expiryDate,
                             forKey: OLString.accessTokenExpiry)
        unprotectedStore.set(true, forKey: OLString.returningUser)
    }
    
    func resumeSession() throws {
        guard expiryDate != nil else {
            throw PersistentSessionError.noSessionExists
        }
        
        guard isSessionValid else {
            throw TokenError.expired
        }
        
        guard hasNotRemovedLocalAuth else {
            throw PersistentSessionError.userRemovedLocalAuth
        }
        
        let keys = try storeKeyService.fetch()
        if let idToken = keys.idToken {
            try user.send(IDTokenUserRepresentation(idToken: idToken))
        } else {
            user.send(nil)
        }
        
        let accessToken = keys.accessToken
        tokenProvider.update(subjectToken: accessToken)
    }
    
    func endCurrentSession() {
        storeKeyService.deleteTokens()
        
        tokenProvider.clear()
        tokenResponse = nil
        user.send(nil)
    }
    
    func clearAllSessionData(restartLoginFlow: Bool) async throws {
        for each in sessionBoundData {
            try await each.delete()
        }
        endCurrentSession()
        
        if restartLoginFlow {
            NotificationCenter.default.post(
                name: .didLogout
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
    func delete() async throws
}
