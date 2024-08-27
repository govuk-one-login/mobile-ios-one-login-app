import Authentication
import LocalAuthentication
import SecureStore

final class PersistentSessionManager: SessionManager {
    private let accessControlEncryptedStore: SecureStorable
    private let encryptedStore: SecureStorable
    private let unprotectedStore: DefaultsStorable
    
    let tokenProvider: TokenHolder
    private(set) var user: (any User)?

    init(accessControlEncryptedStore: SecureStorable,
         encryptedStore: SecureStorable,
         unprotectedStore: DefaultsStorable) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.unprotectedStore = unprotectedStore

        self.tokenProvider = TokenHolder()
    }

    private var persistentID: String? {
        unprotectedStore.value(forKey: .persistentSessionID) as? String
    }

    var expiryDate: Date? {
        unprotectedStore.value(forKey: .accessTokenExpiry) as? Date
    }

    var sessionExists: Bool {
        tokenProvider.accessToken != nil
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

    var isPersistentSessionIDMissing: Bool {
        persistentID == nil && isReturningUser
    }

    func resumeSession() throws {
        let idToken = try accessControlEncryptedStore.readItem(itemName: .idToken)
        user = try IDTokenUserRepresentation(idToken: idToken)

        // TODO: retrieve other values / tokens from storage
    }

//    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel?) {
//        do {
//            try authenticatedStore.delete()
//        } catch {
//            print("Deleting Secure Store error: \(error)")
//        }
//        let laContext = LAContext()
//        if let accessControlLevel {
//            authenticatedStore = SecureStoreService(configuration: .init(id: .oneLoginTokens,
//                                                                         accessControlLevel: accessControlLevel,
//                                                                         localAuthStrings: laContext.contextStrings))
//        } else {
//            authenticatedStore = SecureStoreService(configuration: .init(id: .oneLoginTokens,
//                                                                         accessControlLevel: laContext.isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
//                                                                         localAuthStrings: laContext.contextStrings))
//        }
//    }

    func startSession(using session: any LoginSession) async throws {
        let configuration = LoginSessionConfiguration
            .oneLogin(persistentSessionId: persistentID)
        let response = try await session
            .performLoginFlow(configuration: configuration)

        // update curent state
        tokenProvider.update(tokens: response)
        // TODO: DCMAW-8570 This should be considered non-optional once tokenID work is completed on BE
        if AppEnvironment.callingSTSEnabled,
           let idToken = response.idToken {
            user = try IDTokenUserRepresentation(idToken: idToken)
        } else {
            user = nil
        }

        // persist access / id tokens
        try accessControlEncryptedStore.saveItem(item: response.accessToken, itemName: .accessToken)

        if let idToken = response.idToken {
            try accessControlEncryptedStore.saveItem(item: idToken, itemName: .idToken)
        } else {
            accessControlEncryptedStore.deleteItem(itemName: .idToken)
        }

        if let persistentID = user?.persistentID {
            try encryptedStore.saveItem(item: persistentID, itemName: .persistentSessionID)
        } else {
            encryptedStore.deleteItem(itemName: .persistentSessionID)
        }

        unprotectedStore.set(response.expiryDate, forKey: .accessTokenExpiry)
        unprotectedStore.set(true, forKey: .returningUser)
    }

    func endCurrentSession() {
        accessControlEncryptedStore.deleteItem(itemName: .accessToken)
        accessControlEncryptedStore.deleteItem(itemName: .idToken)

        tokenProvider.clear()
        user = nil
    }

    func clearAllSessionData() {
        encryptedStore.deleteItem(itemName: .persistentSessionID)
        unprotectedStore.removeObject(forKey: .returningUser)
        unprotectedStore.removeObject(forKey: .accessTokenExpiry)
    }
}
