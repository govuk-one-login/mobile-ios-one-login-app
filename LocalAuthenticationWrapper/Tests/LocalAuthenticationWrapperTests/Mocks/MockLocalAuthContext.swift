import LocalAuthentication
@testable import LocalAuthenticationWrapper

final class MockLocalAuthContext: LocalAuthContext {
    var biometryType: LABiometryType = .none
    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?
    var localizedReason: String?
    
    var biometryPolicyOutcome = false
    var anyPolicyOutcome = false
    
    var canEvaluatePolicyError: NSError?
    
    var errorFromEvaluatePolicy: Error?
    var valueFromEvaluatePolicy = true
    
    init(
        localizedFallbackTitle: String? = nil,
        localizedCancelTitle: String? = nil
    ) {
        self.localizedFallbackTitle = localizedFallbackTitle
        self.localizedCancelTitle = localizedCancelTitle
    }
    
    func canEvaluatePolicy(
        _ policy: LAPolicy,
        error: NSErrorPointer
    ) -> Bool {
        error?.pointee = canEvaluatePolicyError
        switch policy {
        case .deviceOwnerAuthenticationWithBiometrics:
            return biometryPolicyOutcome
        case .deviceOwnerAuthentication:
            return anyPolicyOutcome
        @unknown default:
            return false
        }
    }
    
    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String
    ) async throws -> Bool {
        self.localizedReason = localizedReason
        if let errorFromEvaluatePolicy {
            throw errorFromEvaluatePolicy
        }
        return valueFromEvaluatePolicy
    }
}
