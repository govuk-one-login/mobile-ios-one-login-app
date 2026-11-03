import DesignSystem
import LocalAuthenticationWrapper
import SecureStore

protocol LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? { get throws }
}

extension LocalAuthenticationWrapper: LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? {
        get throws {
            LocalAuthenticationLocalizedStrings(
                localizedReason: NSLocalizedString(
                    key: try type == .faceID ?
                    "app_faceId_reason" : "app_touchId_reason",
                    value: "Unlock your phone to continue"
                ),
                localisedFallbackTitle: NSLocalizedString(
                    key: "app_localAuthentication_fallbackTitle",
                    value: "Enter phone passcode"
                ),
                localisedCancelTitle: NSLocalizedString(
                    key: "app_localAuthentication_cancelTitle",
                    value: "Cancel"
                )
            )
        }
    }
}
