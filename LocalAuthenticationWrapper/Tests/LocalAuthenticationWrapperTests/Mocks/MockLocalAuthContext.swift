@testable import LocalAuthenticationWrapper
import LocalAuthentication

final class MockLocalAuthContext: LocalAuthContext {
    var biometryType: LABiometryType = .none
    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?
    var localizedReason: String?
    
    var biometryPolicyOutcome = false
    var anyPolicyOutcome = false
    
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
        switch policy {
        case .deviceOwnerAuthenticationWithBiometrics:
            biometryPolicyOutcome
        case .deviceOwnerAuthentication:
            anyPolicyOutcome
        @unknown default:
            false
        }
    }
    
    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String
    ) async throws -> Bool {
        self.localizedReason = localizedReason
        return true
    }
}
