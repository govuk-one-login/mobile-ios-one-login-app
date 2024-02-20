import LocalAuthentication
@testable import OneLogin

final class MockLAContext: LAContexting {
    var biometryType: LABiometryType = .touchID
    
    var returnedFromEvaluatePolicyForBiometrics: Bool = false
    var returnedFromEvaluatePolicyForAuthentication: Bool = false
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        if policy == .deviceOwnerAuthenticationWithBiometrics {
            return returnedFromEvaluatePolicyForBiometrics
        } else {
            return returnedFromEvaluatePolicyForAuthentication
        }
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        <#code#>
    }
}
