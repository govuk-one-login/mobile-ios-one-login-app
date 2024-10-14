import GDSCommon
import LocalAuthentication
import SecureStore

protocol LocalAuthenticationContext: AnyObject {
    var biometryType: LABiometryType { get }
    var contextStrings: LocalAuthenticationLocalizedStrings? { get }

    var localizedFallbackTitle: String? { get set }
    var localizedCancelTitle: String? { get set }

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: LocalAuthenticationContext { }
extension LocalAuthenticationContext {
    var contextStrings: LocalAuthenticationLocalizedStrings? {
        if canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return LocalAuthenticationLocalizedStrings(
                localizedReason: GDSLocalisedString(
                    stringLiteral: "app_\(biometryType == .touchID ? "touch" : "face")Id_subtitle"
                ).value,
                localisedFallbackTitle: GDSLocalisedString(
                    stringLiteral: "app_enterPasscodeButton"
                ).value,
                localisedCancelTitle: GDSLocalisedString(
                    stringLiteral: "app_cancelButton"
                ).value
            )
        } else {
            return nil
        }
    }
}
