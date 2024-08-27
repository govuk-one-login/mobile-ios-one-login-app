import LocalAuthentication
@testable import OneLogin

final class MockLAContext: LocalAuthFacility {
    var biometryType: LABiometryType = .touchID
    
    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?
    
    var returnedFromCanEvaluatePolicyForBiometrics: Bool = false
    var returnedFromCanEvaluatePolicyForAuthentication: Bool = false
    var errorFromEvaluatePolicy: Error?
    var returnedFromEvaluatePolicy: Bool = true
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        if policy == .deviceOwnerAuthenticationWithBiometrics {
            return returnedFromCanEvaluatePolicyForBiometrics
        } else {
            return returnedFromCanEvaluatePolicyForAuthentication
        }
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        if let errorFromEvaluatePolicy {
            throw errorFromEvaluatePolicy
        }
        return returnedFromEvaluatePolicy
    }
}
