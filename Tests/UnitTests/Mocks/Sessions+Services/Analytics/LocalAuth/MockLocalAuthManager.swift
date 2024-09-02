import LocalAuthentication

final class MockLocalAuthManager: LocalAuthenticationManager {
    var type: LocalAuthenticationType = .touchID
    
    var LABiometricsIsEnabledOnTheDevice = false
    var LAlocalAuthIsEnabledOnTheDevice = false
    var errorFromEnrolLocalAuth: Error?
    var userDidConsentToFaceID = true

    var didCallEnrolFaceIDIfAvailable = false

    func canUseLocalAuth(type policy: LAPolicy) -> Bool {
        if policy == .deviceOwnerAuthenticationWithBiometrics {
            return LABiometricsIsEnabledOnTheDevice
        } else {
            return LAlocalAuthIsEnabledOnTheDevice
        }
    }
    
    func enrolFaceIDIfAvailable() async throws -> Bool {
        didCallEnrolFaceIDIfAvailable = true

        if let errorFromEnrolLocalAuth {
            throw errorFromEnrolLocalAuth
        }
        return userDidConsentToFaceID
    }
}
