import GDSCommon
import LocalAuthenticationWrapper

extension LocalAuthPromptStrings {
    static var oneLogin: LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            subtitle: GDSLocalisedString(
                stringLiteral: "app_faceId_subtitle"
            ).value,
            passcodeButton: GDSLocalisedString(
                stringLiteral: "app_enterPasscodeButton"
            ).value,
            cancelButton: GDSLocalisedString(
                stringLiteral: "app_cancelButton"
            ).value
        )
    }
}
