import GDSCommon
import LocalAuthentication

protocol LAContexting {
    var biometryType: LABiometryType { get }
    
    var localizedFallbackTitle: String? { get set }
    var localizedCancelTitle: String? { get set }
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: LAContexting { }

extension LAContexting {
    mutating func localizeAuthPromptStrings() {
        localizedFallbackTitle = GDSLocalisedString(stringLiteral: "app_enterPasscodeButton").value
        localizedCancelTitle = GDSLocalisedString(stringLiteral: "app_cancelButton").value
    }
}
