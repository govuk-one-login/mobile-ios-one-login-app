import LocalAuthentication
import LocalAuthenticationWrapper

extension LocalAuthPromptStrings {
    static func stub() -> LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            subtitle: "test_reason",
            passcodeButton: "test_passcodeButton",
            cancelButton: "test_cancelButton"
        )
    }
}
