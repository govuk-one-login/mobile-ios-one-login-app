import LocalAuthentication

protocol LAContexting {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
}

extension LAContext: LAContexting { }
