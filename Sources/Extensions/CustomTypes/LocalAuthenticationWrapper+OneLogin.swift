import DesignSystem
import LocalAuthenticationWrapper
import SecureStore

protocol LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings { get }
}

extension LocalAuthenticationWrapper: LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings {
        LocalAuthenticationLocalizedStrings(
            localizedReason: NSLocalizedString(
                key: "app_localAuthentication_reason",
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
