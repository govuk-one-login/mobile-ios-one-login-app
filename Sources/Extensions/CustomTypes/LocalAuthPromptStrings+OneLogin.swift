import DesignSystem
import LocalAuthenticationWrapper

extension LocalAuthPromptStrings {
    static var oneLogin: LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            subtitle: NSLocalizedString(
                key: "app_faceId_reason",
                value: "Unlock your phone to continue"
            ),
            passcodeButton: NSLocalizedString(
                key: "app_localAuthentication_fallbackTitle",
                value: "Enter phone passcode"
            ),
            cancelButton: NSLocalizedString(
                key: "app_localAuthentication_cancelTitle",
                value: "Cancel"
            )
        )
    }
}
