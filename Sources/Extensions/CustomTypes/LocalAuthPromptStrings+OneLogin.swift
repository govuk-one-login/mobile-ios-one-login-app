import DesignSystem
import LocalAuthenticationWrapper

extension LocalAuthPromptStrings {
    static var oneLogin: LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            subtitle: GDSLocalisedString(
                stringLiteral: "app_faceId_reason"
            ).value,
            passcodeButton: GDSLocalisedString(
                stringLiteral: "app_localAuthentication_fallbackTitle"
            ).value,
            cancelButton: GDSLocalisedString(
                stringLiteral: "app_localAuthentication_cancelTitle"
            ).value
        )
    }
}
