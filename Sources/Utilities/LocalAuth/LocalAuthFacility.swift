import GDSCommon
import LocalAuthentication

protocol LocalAuthFacility {
    var biometryType: LABiometryType { get }
    
    var localizedFallbackTitle: String? { get set }
    var localizedCancelTitle: String? { get set }
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: LocalAuthFacility { }

extension LocalAuthFacility {
    mutating func localizeAuthPromptStrings() {
        localizedFallbackTitle = GDSLocalisedString(stringLiteral: "app_enterPasscodeButton").value
        localizedCancelTitle = GDSLocalisedString(stringLiteral: "app_cancelButton").value
    }
    
    var isPasscodeOnly: Bool {
        canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) && !canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
