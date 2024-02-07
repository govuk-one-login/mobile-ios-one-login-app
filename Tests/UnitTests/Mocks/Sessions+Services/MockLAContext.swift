import LocalAuthentication
@testable import OneLogin

final class MockLAContext: LAContexting {
    var biometryType: LABiometryType = .touchID
    
    var returnedFromEvaluatePolicy: Bool = false
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return returnedFromEvaluatePolicy
    }
}
