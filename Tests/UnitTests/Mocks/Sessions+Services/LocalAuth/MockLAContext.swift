import LocalAuthentication
@testable import OneLogin
import SecureStore

final class MockLAContext: LocalAuthenticationContext {
    var biometryType: LABiometryType = .touchID

    var localizedFallbackTitle: String?
    var localizedCancelTitle: String?

    var contextStrings: LocalAuthenticationLocalizedStrings?
    
    var didCallEvaluatePolicy = false

    var biometricsIsEnabledOnTheDevice = false
    var localAuthIsEnabledOnTheDevice = false
    var errorFromEvaluatePolicy: Error?
    var userConsentedToBiometrics = true
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        if policy == .deviceOwnerAuthenticationWithBiometrics {
            return biometricsIsEnabledOnTheDevice
        } else {
            return localAuthIsEnabledOnTheDevice
        }
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        didCallEvaluatePolicy = true
        if let errorFromEvaluatePolicy {
            throw errorFromEvaluatePolicy
        }
        return userConsentedToBiometrics
    }
}
