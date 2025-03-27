import LocalAuthentication

protocol LocalAuthenticationContext: AnyObject {
    var biometryType: LABiometryType { get }

    var localizedFallbackTitle: String? { get set }
    var localizedCancelTitle: String? { get set }

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: LocalAuthenticationContext { }
