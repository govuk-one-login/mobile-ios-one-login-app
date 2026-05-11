import LocalAuthenticationWrapper
@testable import OneLogin
import SecureStore
import XCTest

final class MockLocalAuthManager: LocalAuthManaging, LocalAuthenticationContextStrings {
    var type: LocalAuthType = .touchID
    var deviceBiometricsType: LocalAuthType = .touchID
    
    var oneLoginStrings: LocalAuthenticationLocalizedStrings?
    
    var localAuthIsEnabledOnTheDevice = false
    var errorFromEnrolLocalAuth: Error?
    var userDidConsentToFaceID = true
    var userPromptedForLocalAuth = false
    
    var didCallEnrolFaceIDIfAvailable = false
    
    var canUseAnyLocalAuth: Bool {
        return localAuthIsEnabledOnTheDevice
    }
    
    func checkLevelSupported(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool {
        return true
    }
    
    func hasBeenPrompted() -> Bool {
        return userPromptedForLocalAuth
    }
    
    func promptForFaceIDPermission() async throws -> Bool {
        defer {
            didCallEnrolFaceIDIfAvailable = true
        }
        
        if let errorFromEnrolLocalAuth {
            throw errorFromEnrolLocalAuth
        }
        return userDidConsentToFaceID
    }
}

final class MockLocalAuthManagerExpectation: LocalAuthManaging, LocalAuthenticationContextStrings {
    var type: LocalAuthType {
        mockLocalAuthManager.type
    }
    
    var deviceBiometricsType: LocalAuthType {
        mockLocalAuthManager.deviceBiometricsType
    }
    
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? {
        mockLocalAuthManager.oneLoginStrings
    }
    
    var canUseAnyLocalAuth: Bool {
        mockLocalAuthManager.canUseAnyLocalAuth
    }
    
    let expectation: XCTestExpectation
    let mockLocalAuthManager: MockLocalAuthManager
    
    init(mockLocalAuthManager: MockLocalAuthManager = MockLocalAuthManager(), expectation: XCTestExpectation) {
        self.mockLocalAuthManager = mockLocalAuthManager
        self.expectation = expectation
    }
    
    func checkLevelSupported(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool {
        return try mockLocalAuthManager.checkLevelSupported(requiredLevel)
    }
    
    func hasBeenPrompted() -> Bool {
        return mockLocalAuthManager.userPromptedForLocalAuth
    }
    
    func promptForFaceIDPermission() async throws -> Bool {
        defer {
            expectation.fulfill()
        }
        
        return try await mockLocalAuthManager.promptForFaceIDPermission()
    }
}
