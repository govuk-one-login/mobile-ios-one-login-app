import GDSCommon
import LocalAuthenticationWrapper
import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthWrap & LocalAuthenticationContextStringCheck
    ) throws -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: try localAuthManager.type == .passcode ?
                .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.contextStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
    }
    
    static func encryptedStore() -> SecureStoreService {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.persistentSessionID,
            accessControlLevel: .open
        )
        return SecureStoreService(configuration: encryptedConfiguration)
    }
}

extension SecureStoreService: SessionBoundData { }

protocol LocalAuthenticationContextStringCheck {
    var contextStrings: LocalAuthenticationLocalizedStrings? { get throws }
}

extension LocalAuthenticationWrapper: LocalAuthenticationContextStringCheck {
    var contextStrings: LocalAuthenticationLocalizedStrings? {
        get throws {
            LocalAuthenticationLocalizedStrings(
                localizedReason: GDSLocalisedString(
                    stringLiteral: try type == .faceID ? "app_faceId_subtitle" : "app_touchId_subtitle"
                ).value,
                localisedFallbackTitle: GDSLocalisedString(
                    stringLiteral: "app_enterPasscodeButton"
                ).value,
                localisedCancelTitle: GDSLocalisedString(
                    stringLiteral: "app_cancelButton"
                ).value
            )
        }
    }
}
