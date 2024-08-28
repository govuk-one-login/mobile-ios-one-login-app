import LocalAuthentication
@testable import OneLogin
import SecureStore

final class MockLAContext: LocalAuthenticationContext {
    var biometryType: LABiometryType = .touchID

    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?

    var contextStrings: LocalAuthenticationLocalizedStrings?

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
