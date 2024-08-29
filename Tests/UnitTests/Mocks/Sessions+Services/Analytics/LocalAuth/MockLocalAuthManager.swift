import LocalAuthentication

final class MockLocalAuthManager: LocalAuthenticationManager {
    var type: LocalAuthenticationType = .touchID
    
    var returnedFromCanUseLocalAuthForBiometrics: Bool = false
    var returnedFromCanUseLocalAuthForAuthentication: Bool = false
    var errorFromEnrolLocalAuth: Error?
    var returnedFromEnrolLocalAuth: Bool = true
    
    func canUseLocalAuth(type policy: LAPolicy) -> Bool {
        if policy == .deviceOwnerAuthenticationWithBiometrics {
            return returnedFromCanUseLocalAuthForBiometrics
        } else {
            return returnedFromCanUseLocalAuthForAuthentication
        }
    }
    
    func enrolFaceIDIfAvailable() async throws -> Bool {
        if let errorFromEnrolLocalAuth {
            throw errorFromEnrolLocalAuth
        }
        return returnedFromEnrolLocalAuth
    }
}
