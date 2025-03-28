import LocalAuthentication
@testable import LocalAuthenticationWrapper
import Testing

struct LocalAuthenticationWrapperTests {
    private var mockLocalAuthContext: MockLocalAuthContext!
    private var mockAuthPromptStore: MockLocalAuthPromptRecorder!
    private var sut: LocalAuthenticationWrapper!
    
    init() {
        mockLocalAuthContext = MockLocalAuthContext()
        mockAuthPromptStore = MockLocalAuthPromptRecorder()
        sut = LocalAuthenticationWrapper(
            localAuthContext: mockLocalAuthContext,
            localAuthPromptStore: mockAuthPromptStore,
            localAuthStrings: LocalAuthPromptStrings(
                subtitle: "test_reason",
                passcodeButton: "test_passcodeButton",
                cancelButton: "test_cancelButton"
            )
        )
    }
    
    @Test("Check that none is returned when no authentication method is available")
    func typeNone() throws {
        #expect(try sut.type == .none)
    }
    
    @Test("Check that passcode is returned when available")
    func typePasscode() throws {
        mockLocalAuthContext.anyPolicyOutcome = true
        #expect(try sut.type == .passcode)
    }
    
    @Test("Check that touchID is returned when available")
    func typeTouchID() throws {
        mockLocalAuthContext.biometryType = .touchID
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.type == .touchID)
    }
    
    @Test("Check that faceID is returned when available")
    func typeFaceID() throws {
        mockLocalAuthContext.biometryType = .faceID
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.type == .faceID)
    }
    
    @Test("Check that error is thrown from type when biometrics unavailable")
    func canUseLocalAuthBiometricError() throws {
        mockLocalAuthContext.canEvaluatePolicyError = NSError(
            domain: LAErrorDomain,
            code: LAError.biometryNotEnrolled.rawValue
        )
        
        #expect(
            throws: LocalAuthenticationWrapperError.biometricsUnavailable
        ) {
            try sut.type
        }
    }
    
    @Test("Check that error is thrown from type when unknown error")
    func canUseLocalAuthUnknownError() throws {
        mockLocalAuthContext.canEvaluatePolicyError = NSError(
            domain: LAErrorDomain,
            code: LAError.invalidContext.rawValue
        )
        
        #expect(
            throws: NSError(
                domain: LAErrorDomain,
                code: LAError.invalidContext.rawValue
            )
        ) {
            try sut.type
        }
    }
    
    @Test("Check level supported any biometrics is true")
    func checkMinimumLevelAnyBiometricsTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.checkLevelSupported(.anyBiometrics))
    }
    
    @Test("Check level supported any biometrics is false")
    func checkMinimumLevelAnyBiometricsFalse() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = true
        #expect(try !sut.checkLevelSupported(.anyBiometrics))
    }
    
    @Test("Check level supported passcode only is true")
    func checkMinimumLevelPasscodeTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = true
        #expect(try sut.checkLevelSupported(.passcodeOnly))
    }
    
    @Test("Check level supported passcode only is false")
    func checkMinimumLevelPasscodeFalse() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = false
        #expect(try !sut.checkLevelSupported(.passcodeOnly))
    }
    
    @Test("Check level supported none is true")
    func checkMinimumLevelNoneTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = false
        #expect(try sut.checkLevelSupported(.none))
    }
    
    @Test("Check prompt for permissions touchID returns true")
    func enrolLocalAuthNotFaceID() async throws {
        mockLocalAuthContext.biometryType = .touchID
        #expect(try await sut.promptForPermissions())
    }
    
    @Test("Check prompt for permissions faceID but previously prompted returns true")
    func enrolLocalAuthAlreadyPrompted() async throws {
        mockLocalAuthContext.biometryType = .faceID
        mockAuthPromptStore.recordPrompt()
        #expect(try await sut.promptForPermissions())
    }
    
    @Test("Check prompt for permissions faceID sets localized strings")
    func enrolLocalAuthStrings() async throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        _ = try await sut.promptForPermissions()
        #expect(mockLocalAuthContext.localizedFallbackTitle == "test_passcodeButton")
        #expect(mockLocalAuthContext.localizedCancelTitle == "test_cancelButton")
        #expect(mockLocalAuthContext.localizedReason == "test_reason")
    }
    
    @Test("Check prompt for permissions faceID records prompt")
    func enrolLocalAuthPromptSet() async throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        _ = try await sut.promptForPermissions()
        #expect(mockAuthPromptStore.previouslyPrompted == true)
    }
    
    @Test("Check prompt for permissions faceID cancel error")
    func enrolLocalAuthCancelError() async {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        mockLocalAuthContext.errorFromEvaluatePolicy = LAError(
            _nsError: NSError(domain: LAErrorDomain, code: LAError.userCancel.rawValue)
        )
        
        await #expect(throws: LocalAuthenticationWrapperError.cancelled) {
            try await sut.promptForPermissions()
        }
    }
    
    @Test("Check prompt for permissions faceID unknown error")
    func enrolLocalAuthUnknownError() async {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        mockLocalAuthContext.errorFromEvaluatePolicy = LAError(
            _nsError: NSError(
                domain: LAErrorDomain,
                code: LAError.authenticationFailed.rawValue
            )
        )
        
        await #expect(
            throws: NSError(
                domain: LAErrorDomain,
                code: LAError.authenticationFailed.rawValue
            )
        ) {
            try await sut.promptForPermissions()
        }
    }
}
