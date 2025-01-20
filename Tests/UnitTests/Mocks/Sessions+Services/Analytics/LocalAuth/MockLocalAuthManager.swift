import LocalAuthentication
import SecureStore

final class MockLocalAuthManager: LocalAuthenticationManager, LocalAuthenticationContextStringCheck {
    var type: LocalAuthenticationType = .touchID

    var contextStrings: LocalAuthenticationLocalizedStrings?
    
    var localAuthPresent = false
    var errorFromEnrolLocalAuth: Error?
    var userDidConsentToFaceID = true

    var didCallEnrolFaceIDIfAvailable = false

    var canUseAnyLocalAuth: Bool {
        localAuthPresent
    }
    
    func enrolFaceIDIfAvailable() async throws -> Bool {
        didCallEnrolFaceIDIfAvailable = true

        if let errorFromEnrolLocalAuth {
            throw errorFromEnrolLocalAuth
        }
        return userDidConsentToFaceID
    }
}
