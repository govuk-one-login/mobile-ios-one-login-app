import LocalAuthentication

protocol LAContexting {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    var biometryType: LABiometryType { get }
}

extension LAContext: LAContexting { }
