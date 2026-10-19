import LocalAuthenticationWrapper
@testable import OneLogin
import SecureStore

final class MockLocalAuthManager: LocalAuthManaging, LocalAuthenticationContextStrings {
    static func errorFromOneLoginStringsAsFunction(error: Error) -> MockLocalAuthManager {
        func oneLoginStringsAsFunction() throws -> LocalAuthenticationLocalizedStrings? {
            throw error
        }

        return MockLocalAuthManager(oneLoginStringsAsFunction: oneLoginStringsAsFunction)
    }

    static func oneLoginStringsAsFunction(oneLoginStrings: LocalAuthenticationLocalizedStrings? = nil) -> OneLoginStringsAsFunction {
        func oneLoginStringsAsFunction() throws -> LocalAuthenticationLocalizedStrings? {
            return oneLoginStrings
        }

        return oneLoginStringsAsFunction
    }

    static func oneLoginStringsAsFunction(oneLoginStrings: LocalAuthenticationLocalizedStrings? = nil) -> OneLoginStringsTypeAsFunction {
        func oneLoginStringsAsFunction(type: LocalAuthType) -> LocalAuthenticationLocalizedStrings? {
            return oneLoginStrings
        }

        return oneLoginStringsAsFunction
    }

    typealias OneLoginStringsTypeAsFunction = (LocalAuthType) -> LocalAuthenticationLocalizedStrings?
    typealias OneLoginStringsAsFunction = () throws -> LocalAuthenticationLocalizedStrings?

    var type: LocalAuthType = .touchID
    var deviceBiometricsType: LocalAuthType = .touchID

    let oneLoginStringsTypeAsFunction: OneLoginStringsTypeAsFunction
    let oneLoginStringsAsFunction: OneLoginStringsAsFunction
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? {
        get throws {
            return try self.oneLoginStringsAsFunction()
        }
    }
    
    var localAuthIsEnabledOnTheDevice = false
    var errorFromEnrolLocalAuth: Error?
    var userDidConsentToFaceID = true
    var userPromptedForLocalAuth = false
    
    var didCallEnrolFaceIDIfAvailable = false
    
    init(type: LocalAuthType = .none,
         deviceBiometricsType: LocalAuthType = .none,
         oneLoginStringsAsFunction: @escaping OneLoginStringsAsFunction = MockLocalAuthManager.oneLoginStringsAsFunction(),
         oneLoginStringsTypeAsFunction: @escaping OneLoginStringsTypeAsFunction = MockLocalAuthManager.oneLoginStringsAsFunction(),
         localAuthIsEnabledOnTheDevice: Bool = false,
         errorFromEnrolLocalAuth: Error? = nil,
         userDidConsentToFaceID: Bool = true,
         userPromptedForLocalAuth: Bool = false,
         didCallEnrolFaceIDIfAvailable: Bool = false) {
        self.type = type
        self.deviceBiometricsType = deviceBiometricsType
        self.oneLoginStringsAsFunction = oneLoginStringsAsFunction
        self.oneLoginStringsTypeAsFunction = oneLoginStringsTypeAsFunction
        self.localAuthIsEnabledOnTheDevice = localAuthIsEnabledOnTheDevice
        self.errorFromEnrolLocalAuth = errorFromEnrolLocalAuth
        self.userDidConsentToFaceID = userDidConsentToFaceID
        self.userPromptedForLocalAuth = userPromptedForLocalAuth
        self.didCallEnrolFaceIDIfAvailable = didCallEnrolFaceIDIfAvailable
    }

    var canUseAnyLocalAuth: Bool {
        return localAuthIsEnabledOnTheDevice
    }
    
    func checkLevelSupported(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool {
        return true
    }
    
    func oneLoginStrings(type: LocalAuthType) -> LocalAuthenticationLocalizedStrings? {
        return oneLoginStringsTypeAsFunction(type)
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
        get throws {
            try mockLocalAuthManager.oneLoginStrings
        }
    }
    
    func oneLoginStrings(type: LocalAuthType) -> SecureStore.LocalAuthenticationLocalizedStrings? {
        return mockLocalAuthManager.oneLoginStrings(type: type)
    }

    var canUseAnyLocalAuth: Bool {
        mockLocalAuthManager.canUseAnyLocalAuth
    }
    
    let mockLocalAuthManager: MockLocalAuthManager
    var onPromptForFaceIDPermission: () -> Void
    
    init(mockLocalAuthManager: MockLocalAuthManager = MockLocalAuthManager(), onPromptForFaceIDPermission: @escaping () -> Void) {
        self.mockLocalAuthManager = mockLocalAuthManager
        self.onPromptForFaceIDPermission = onPromptForFaceIDPermission
    }
    
    func checkLevelSupported(_ requiredLevel: RequiredLocalAuthLevel) throws -> Bool {
        return try mockLocalAuthManager.checkLevelSupported(requiredLevel)
    }
    
    func hasBeenPrompted() -> Bool {
        return mockLocalAuthManager.userPromptedForLocalAuth
    }
    
    func promptForFaceIDPermission() async throws -> Bool {
        defer {
            onPromptForFaceIDPermission()
        }
        
        return try await mockLocalAuthManager.promptForFaceIDPermission()
    }
}
