import AppIntegrity
import Authentication
import Combine
import Foundation
import GDSUtilities
import LocalAuthenticationWrapper
import Logging
import SecureStore

// swiftlint:disable:next type_body_length
final class PersistentSessionManager: SessionManager {
    private let accessControlEncryptedStore: SecureStorableV2
    private let encryptedStore: SecureStorableV2
    private let storeKeyService: TokenStore
    private let unprotectedStore: DefaultsStoring
    private let analyticsService: OneLoginAnalyticsService
    private let walletSDK: WalletServiceProtocol
    
    let localAuthentication: LocalAuthManaging
    let tokenProvider: TokenHolder
    
    var isEnrolling: Bool = false
    
    private var sessionBoundData = [SessionBoundData]()
    
    let user = CurrentValueSubject<(any User)?, Never>(nil)
    
    convenience init(
        accessControlEncryptedStore: SecureStorableV2,
        encryptedStore: SecureStorableV2,
        analyticsService: OneLoginAnalyticsService
    ) {
        self.init(
            accessControlEncryptedStore: accessControlEncryptedStore,
            encryptedStore: encryptedStore,
            unprotectedStore: UserDefaults.standard,
            localAuthentication: LocalAuthenticationWrapper(localAuthStrings: .oneLogin),
            analyticsService: analyticsService,
            walletSDK: WalletSDKWrapper()
        )
    }
    
    init(
        accessControlEncryptedStore: SecureStorableV2,
        encryptedStore: SecureStorableV2,
        unprotectedStore: DefaultsStoring,
        localAuthentication: LocalAuthManaging,
        analyticsService: OneLoginAnalyticsService,
        walletSDK: WalletServiceProtocol = WalletSDKWrapper()
    ) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.storeKeyService = SecureTokenStore(
            accessControlEncryptedStore: accessControlEncryptedStore
        )
        self.unprotectedStore = unprotectedStore
        self.localAuthentication = localAuthentication
        
        self.tokenProvider = TokenHolder()
        self.analyticsService = analyticsService
        self.walletSDK = walletSDK
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
        guard let accessTokenExpiry = tokenProvider.accessTokenExpiry else {
            return false
        }
        return isEnrolling && accessTokenExpiry > .now
    }
    
    private var isOneTimeUser: Bool {
        tokenProvider.accessToken != nil && !isReturningUser
    }
    
    var expiryDate: Date? {
        ((try? encryptedStore.readDate(id: OLString.refreshTokenExpiry))
         ?? unprotectedStore.value(forKey: OLString.accessTokenExpiry) as? Date)?
            .withFifteenSecondBuffer
    }
    
    var isSessionValid: Bool {
        guard let expiryDate else {
            return false
        }
        // Fifteen second buffer for access token expiry when user comes in to perform an ID Check
        return expiryDate > .now
    }
    
    var validTokensForRefreshExchange: (idToken: String, refreshToken: String)? {
        get throws {
            let expiryDate = try? encryptedStore.readDate(id: OLString.refreshTokenExpiry)
            
            guard let actualExpiryDate = expiryDate,
                  actualExpiryDate.withFifteenSecondBuffer > .now else {
                return nil
            }
            
            let storedTokens = try storeKeyService.fetch()
            
            guard let idToken = storedTokens.idToken,
                  let refreshToken = storedTokens.refreshToken else {
                return nil
            }
            
            return (idToken: idToken, refreshToken: refreshToken)
        }
    }
    
    var isReturningUser: Bool {
        get {
            unprotectedStore.bool(forKey: OLString.returningUser)
        }
        set {
            unprotectedStore.set(
                newValue,
                forKey: OLString.returningUser
            )
        }
    }
    
    var persistentID: String? {
        guard let persistenID = try? encryptedStore
            .readItem(itemName: OLString.persistentSessionID),
              !persistenID.isEmpty else { return nil }
        return persistenID
    }
    
    var walletStoreID: String? {
        return user.value?.walletStoreID
    }
    
    private var hasNotRemovedLocalAuth: Bool {
        (try? localAuthentication.canUseAnyLocalAuth) ?? false && isReturningUser
    }
    
    func startAuthSession(
        _ session: any LoginSession,
        using configuration: @Sendable (String?) async throws -> LoginSessionConfiguration
    ) async throws {
        if persistentID == nil {
            if isReturningUser {
                // I am a returning user
                // but cannot reauthenticate because I don't have a persistent session ID
                //
                // I need to delete my session & Wallet data before I can login
                do {
                    if await !walletSDK.isEmpty() {
                        analyticsService.logCrash(PersistentSessionError(.sessionMismatch,
                                                                         reason: "secure wallet data deleted"))
                    }
                    try await clearAllSessionData(presentSystemLogOut: true)
                } catch {
                    throw PersistentSessionError(.cannotDeleteData, originalError: error)
                }
                
                throw PersistentSessionError(.sessionMismatch)
            } else {
                // I am a first time user
                // I don't have a persistent session ID
                //
                // I need to delete my session (but not analytics permissions) & Wallet data before I can login
                do {
                    if await !walletSDK.isEmpty() {
                        analyticsService.logCrash(PersistentSessionError(.noSessionExists,
                                                                         reason: "secure wallet data deleted"))
                    }
                    try await clearAppForLogin()
                } catch {
                    throw PersistentSessionError(.cannotDeleteData, originalError: error)
                }
            }
        }
        
        let response = try await session.performLoginFlow(
            configuration: configuration(persistentID)
        )
        
        tokenProvider.update(
            idToken: response.idToken,
            refreshToken: response.refreshToken,
            accessToken: response.accessToken,
            accessTokenExpiry: response.expiryDate
        )
        
        // TODO: DCMAW-8570 This should be considered non-optional once tokenID work is completed on BE
        if let idToken = response.idToken {
            await user.send(try IDTokenUserRepresentation(verify: idToken))
        } else {
            user.send(nil)
        }
        
        guard isReturningUser else {
            // user has not yet enroled in local authentication
            // so tokens should not be saved !
            return
        }
        
        try saveAuthSession()
        
        NotificationCenter.default.post(name: .enrolmentComplete)
    }
    
    func saveAuthSession() throws {
        if let persistentID = user.value?.persistentID {
            try encryptedStore.saveItem(
                item: persistentID,
                itemName: OLString.persistentSessionID
            )
        } else {
            encryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        }
        
        try saveLoginTokens(
            idToken: tokenProvider.idToken,
            refreshToken: tokenProvider.refreshToken,
            accessToken: tokenProvider.accessToken,
            accessTokenExpiry: tokenProvider.accessTokenExpiry
        )
        
        isReturningUser = true
    }
    
    func resumeSession(
        tokenExchangeManager: TokenExchangeManaging,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws {
        guard hasNotRemovedLocalAuth else {
            // Underlying error here is LAError.passcodeNotSet
            // This error will result in user being signed out and their data deleted
            throw PersistentSessionError(.userRemovedLocalAuth)
        }
        
        guard persistentID != nil else {
            throw PersistentSessionError(.noSessionExists)
        }
        
        let storedTokens = try storeKeyService.fetch()
        
        guard let idToken = storedTokens.idToken,
              !idToken.isEmpty else {
            throw PersistentSessionError(.idTokenNotStored)
        }
        
        // don't verify jwks token because the user won't be able to login offline
        user.send(try IDTokenUserRepresentation(idToken: idToken))
        
        // Enables offline wallet for users that only have access tokens
        tokenProvider.update(
            accessToken: storedTokens.accessToken,
            accessTokenExpiry: storedTokens.accessTokenExpiry
        )
        
        guard let refreshToken = storedTokens.refreshToken else {
            return
        }
        
        do {
            let exchangeTokenResponse = try await tokenExchangeManager.getUpdatedTokens(
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
            
            try saveLoginTokens(
                idToken: idToken,
                refreshToken: exchangeTokenResponse.refreshToken,
                accessToken: exchangeTokenResponse.accessToken,
                accessTokenExpiry: exchangeTokenResponse.expiryDate
            )
        } catch RefreshTokenExchangeError.noInternet {
            // Enables offline wallet for users that have valid refresh tokens
            return
        }
    }
    
    func saveLoginTokens(
        idToken: String?,
        refreshToken: String?,
        accessToken: String?,
        accessTokenExpiry: Date?
    ) throws {
        if let refreshToken {
            try encryptedStore.saveDate(
                id: OLString.refreshTokenExpiry,
                try RefreshTokenRepresentation(refreshToken: refreshToken).expiryDate
            )
        } else {
            encryptedStore.deleteItem(itemName: OLString.refreshTokenExpiry)
        }
        
        let tokens = StoredTokens(
            idToken: idToken,
            refreshToken: refreshToken,
            accessToken: accessToken,
            accessTokenExpiry: accessTokenExpiry
        )
        
        try storeKeyService.save(tokens: tokens)
        
        tokenProvider.update(
            accessToken: accessToken,
            accessTokenExpiry: accessTokenExpiry
        )
        
        unprotectedStore.set(
            accessTokenExpiry,
            forKey: OLString.accessTokenExpiry
        )
    }
    
    func endCurrentSession() {
        storeKeyService.deleteTokens()
        
        tokenProvider.clear()
        user.send(nil)
    }
    
    func clearAppForLogin() async throws {
        for each in sessionBoundData where type(of: each) != UserDefaultsPreferenceStore.self {
            try await each.clearSessionData()
        }
        
        endCurrentSession()
    }

    func clearAllSessionData(presentSystemLogOut: Bool) async throws {
        for each in sessionBoundData {
            try await each.clearSessionData()
        }
        
        endCurrentSession()
        
        if presentSystemLogOut {
            NotificationCenter.default.post(name: .systemLogUserOut)
        }
    }
    
    func registerSessionBoundData(_ data: [SessionBoundData]) {
        sessionBoundData = data
    }
}

public enum PersistentSessionErrorKind: String, GDSErrorKind {
    case noSessionExists = "there was no persistentID token saved in the encrypted store"
    case userRemovedLocalAuth = "the user has removed all local auth from their device"
    case sessionMismatch = "the persistentID was cleared from the encrypted store because a different user logged in"
    case cannotDeleteData = "there was an error while trying to delete all user data"
    case idTokenNotStored = "there was no idToken found in the secure store"
}

public typealias PersistentSessionError = OneLoginGDSError<PersistentSessionErrorKind>

protocol SessionBoundData {
    func clearSessionData() async throws
}
