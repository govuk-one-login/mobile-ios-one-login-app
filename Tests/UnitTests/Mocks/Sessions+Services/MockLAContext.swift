import LocalAuthentication
@testable import OneLogin

final class MockLAContext: LAContexting {
    
    var returnedFromEvaluatePolicy: Bool = false
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return returnedFromEvaluatePolicy
    }
}
