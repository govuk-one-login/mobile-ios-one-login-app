import GDSCommon
import LocalAuthenticationWrapper

extension LocalAuthPromptStrings {
    static var oneLogin: LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            faceIdSubtitle: GDSLocalisedString(
                stringLiteral: "app_faceId_subtitle"
            ).value,
            touchIdSubtitle: GDSLocalisedString(
                stringLiteral: "app_touchId_subtitle"
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
