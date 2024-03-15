import GDSCommon
import LocalAuthentication
import SecureStore

extension LAContext {
    var contextStrings: LocalAuthenticationLocalizedStrings? {
        if canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if biometryType == .faceID {
                LocalAuthenticationLocalizedStrings(localizedReason: GDSLocalisedString(stringLiteral: "app_faceId_subtitle").value,
                                                    localisedFallbackTitle: GDSLocalisedString(stringLiteral: "app_enterPasscodeButton").value,
                                                    localisedCancelTitle: GDSLocalisedString(stringLiteral: "app_cancelButton").value)
            } else if biometryType == .touchID {
                LocalAuthenticationLocalizedStrings(localizedReason: GDSLocalisedString(stringLiteral: "app_touchId_subtitle").value,
                                                    localisedFallbackTitle: GDSLocalisedString(stringLiteral: "app_enterPasscodeButton").value,
                                                    localisedCancelTitle: GDSLocalisedString(stringLiteral: "app_cancelButton").value)
            } else {
                nil
            }
        } else {
            nil
        }
    }
}
