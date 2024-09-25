import Authentication
import Combine
import LocalAuthentication
import Networking
import SecureStore

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
    func delete() throws
}

final class PersistentSessionManager: SessionManager {
    private let encryptedStore: SecureStorable
    private let unprotectedStore: DefaultsStorable

    let localAuthentication: LocalAuthenticationManager

    let tokenProvider: TokenHolder
    private var tokenResponse: TokenResponse?
    private let storeKeyService: TokenStore

    let user = CurrentValueSubject<(any User)?, Never>(nil)

    private var sessionBoundData: [SessionBoundData] = []

    init(accessControlEncryptedStore: SecureStorable,
         encryptedStore: SecureStorable,
         unprotectedStore: DefaultsStorable,
         localAuthentication: LocalAuthenticationManager) {
        self.storeKeyService = SecureTokenStore(accessControlEncryptedStore: accessControlEncryptedStore)
        self.encryptedStore = encryptedStore
        self.unprotectedStore = unprotectedStore
        self.localAuthentication = localAuthentication

        self.tokenProvider = TokenHolder()
    }

    convenience init(context: LocalAuthenticationContext = LAContext()) {
        let localAuthentication = LALocalAuthenticationManager(context: context)
        // Due to a possible Apple bug, .currentBiometricsOrPasscode does not allow creation of private
        // keys in the secure enclave if no biometrics are registered on the device.
        // Hence the store needs to be created with access controls that allow it
        let accessControlConfiguration = SecureStorageConfiguration(
            id: .oneLoginTokens,
            accessControlLevel: localAuthentication.type == .passcodeOnly ?
                .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
            localAuthStrings: context.contextStrings
        )

        let encryptedConfiguration = SecureStorageConfiguration(
            id: .persistentSessionID,
            accessControlLevel: .open
        )

        self.init(
            accessControlEncryptedStore: SecureStoreService(configuration: accessControlConfiguration),
            encryptedStore: SecureStoreService(configuration: encryptedConfiguration),
            unprotectedStore: UserDefaults.standard,
            localAuthentication: localAuthentication
        )
    }

    private var persistentID: String? {
        try? encryptedStore.readItem(itemName: .persistentSessionID)
    }

    var expiryDate: Date? {
        unprotectedStore.value(forKey: .accessTokenExpiry) as? Date
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
        unprotectedStore.value(forKey: .returningUser) as? Bool
            ?? false
    }
    
    var isOneTimeUser: Bool {
        sessionExists && !isReturningUser
    }
    
    private var hasNotRemovedLocalAuth: Bool {
        localAuthentication.canUseLocalAuth(type: .deviceOwnerAuthentication) && isReturningUser
    }
    
    func startSession(using session: any LoginSession) async throws {
        guard !isReturningUser || persistentID != nil else {
            // I am a returning user
            // but cannot reauthenticate because I don't have a persistent session ID
            //
            // I need to delete my session & Wallet data before I can login
            do {
                try clearAllSessionData()
            } catch {
                throw PersistentSessionError.cannotDeleteData(error)
            }

            throw PersistentSessionError.sessionMismatch
        }

        let configuration = LoginSessionConfiguration
            .oneLogin(persistentSessionId: persistentID)
        let response = try await session
            .performLoginFlow(configuration: configuration)
        tokenResponse = response

        // update curent state
        tokenProvider.update(subjectToken: response.accessToken)
        // TODO: DCMAW-8570 This should be considered non-optional once tokenID work is completed on BE
        if AppEnvironment.callingSTSEnabled,
           let idToken = response.idToken {
            try user.send(IDTokenUserRepresentation(idToken: idToken))
        } else {
            user.send(nil)
        }

        guard isReturningUser else {
            // user has not yet enrolled in local authentication
            // so tokens should not be saved !
            return
        }

        try await saveSession()

        NotificationCenter.default.post(name: .enrolmentComplete)
    }

    func saveSession() async throws {
        guard let tokenResponse else {
            assertionFailure("Could not save session as token response was not set")
            return
        }

        if !isReturningUser {
            guard try await localAuthentication.enrolFaceIDIfAvailable() else {
                // first time user fails FaceID scan
                // so tokens should not be saved !
                return
            }
        }

        let tokens = StoredTokens(idToken: tokenResponse.idToken,
                                  accessToken: tokenResponse.accessToken)

        if !ProcessInfo.processInfo.arguments.contains("uiTests") {
            try storeKeyService.save(tokens: tokens)

            if let persistentID = user.value?.persistentID {
                try encryptedStore.saveItem(item: persistentID,
                                            itemName: .persistentSessionID)
            } else {
                encryptedStore.deleteItem(itemName: .persistentSessionID)
            }
        }

        unprotectedStore.set(tokenResponse.expiryDate,
                             forKey: .accessTokenExpiry)
        unprotectedStore.set(true, forKey: .returningUser)
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
        storeKeyService.delete()

        tokenProvider.clear()
        tokenResponse = nil
        user.send(nil)
    }

    func clearAllSessionData() throws {
        try sessionBoundData.forEach {
            try $0.delete()
        }

        encryptedStore.deleteItem(itemName: .persistentSessionID)
        unprotectedStore.removeObject(forKey: .returningUser)
        unprotectedStore.removeObject(forKey: .accessTokenExpiry)

        NotificationCenter.default.post(name: .didLogout)
    }

    func registerSessionBoundData(_ data: SessionBoundData) {
        sessionBoundData.append(data)
    }
}
