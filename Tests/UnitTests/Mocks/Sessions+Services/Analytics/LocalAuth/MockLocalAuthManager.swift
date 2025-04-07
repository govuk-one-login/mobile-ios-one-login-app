import LocalAuthenticationWrapper
@testable import OneLogin
import SecureStore

final class MockLocalAuthManager: LocalAuthWrap, LocalAuthenticationContextStrings {
    var type: LocalAuthType = .touchID
    
    var oneLoginStrings: LocalAuthenticationLocalizedStrings?
    
    var localAuthIsEnabledOnTheDevice = false
    var errorFromEnrolLocalAuth: Error?
    var userDidConsentToFaceID = true
    
    var didCallEnrolFaceIDIfAvailable = false
    
    var canUseAnyLocalAuth: Bool {
        return localAuthIsEnabledOnTheDevice
    }
    
    func checkLevelSupported(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool {
        return true
    }
    
    func promptForPermission() async throws -> Bool {
        defer {
            didCallEnrolFaceIDIfAvailable = true
        }
        
        if let errorFromEnrolLocalAuth {
            throw errorFromEnrolLocalAuth
        }
        return userDidConsentToFaceID
    }
}
