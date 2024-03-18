import GDSCommon
import LocalAuthentication
import SecureStore

extension LAContext {
    var contextStrings: LocalAuthenticationLocalizedStrings? {
        if canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            let biometryTypeString = biometryType == .touchID ? "touch" : "face"
            return LocalAuthenticationLocalizedStrings(localizedReason: GDSLocalisedString(stringLiteral: "app_\(biometryTypeString)Id_subtitle").value,
                                                       localisedFallbackTitle: GDSLocalisedString(stringLiteral: "app_enterPasscodeButton").value,
                                                       localisedCancelTitle: GDSLocalisedString(stringLiteral: "app_cancelButton").value)
        } else {
            return nil
        }
    }
}
