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

    convenience init(context: LocalAuthenticationContext = LAContext()) {
        // Due to a possible Apple bug, .currentBiometricsOrPasscode does not allow creation of private
        // keys in the secure enclave if no biometrics are registered on the device.
        // Hence the store needs to be created with access controls that allow it
        let accessControlConfiguration = SecureStorageConfiguration(
            id: .oneLoginTokens,
            accessControlLevel: context.isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
            localAuthStrings: context.contextStrings
        )

        let encryptedConfiguration = SecureStorageConfiguration(
            id: .persistentSessionID,
            accessControlLevel: .open,
            localAuthStrings: context.contextStrings
        )

        self.init(
            accessControlEncryptedStore: SecureStoreService(configuration: accessControlConfiguration),
            encryptedStore: SecureStoreService(configuration: encryptedConfiguration),
            unprotectedStore: UserDefaults.standard
        )
    }

    private var persistentID: String? {
        try? encryptedStore.readItem(itemName: .persistentSessionID)
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

    func startSession(using session: any LoginSession) async throws {
        let configuration = LoginSessionConfiguration
            .oneLogin(persistentSessionId: persistentID)
        let response = try await session
            .performLoginFlow(configuration: configuration)

        // update curent state
        tokenProvider.update(accessToken: response.accessToken)
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

    func resumeSession() throws {
        let idToken = try accessControlEncryptedStore
            .readItem(itemName: .idToken)
        user = try IDTokenUserRepresentation(idToken: idToken)

        let accessToken = try accessControlEncryptedStore
            .readItem(itemName: .accessToken)
        tokenProvider.update(accessToken: accessToken)
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
