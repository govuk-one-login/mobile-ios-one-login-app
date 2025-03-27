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
        #expect(try sut.type == .passcodeOnly)
    }
    
    @Test("Check that touchID is returned when available")
    func typeTouchID() throws {
        mockLocalAuthContext.biometryType = .touchID
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.type == .biometry(type: .touchID))
    }
    
    @Test("Check that faceID is returned when available")
    func typeFaceID() throws {
        mockLocalAuthContext.biometryType = .faceID
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.type == .biometry(type: .faceID))
    }
    
    @Test("")
    func canUseLocalAuthBiometricError() throws {
        mockLocalAuthContext.canEvaluatePolicyError = NSError(
            domain: "LAErrorDomain",
            code: LAError.biometryNotEnrolled.rawValue
        )
        
        #expect(
            throws: LocalAuthenticationWrapperError.biometricsUnavailable
        ) {
            try sut.type
        }
    }
    
    @Test("")
    func canUseLocalAuthUnknownError() throws {
        mockLocalAuthContext.canEvaluatePolicyError = NSError(
            domain: "LAErrorDomain",
            code: LAError.invalidContext.rawValue
        )
        
        #expect(
            throws: NSError(
                domain: "LAErrorDomain",
                code: LAError.invalidContext.rawValue
            )
        ) {
            try sut.type
        }
    }
    
    @Test("Check minimum level biometry faceID is true")
    func checkMinimumLevelFaceIDTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.checkMinimumLevel(.biometry(type: .faceID)))
    }
    
    @Test("Check minimum level biometry faceID is false")
    func checkMinimumLevelFaceIDFalse() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = true
        #expect(try !sut.checkMinimumLevel(.biometry(type: .faceID)))
    }
    
    @Test("Check minimum level biometry touchID is true")
    func checkMinimumLevelTouchIDTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        #expect(try sut.checkMinimumLevel(.biometry(type: .touchID)))
    }
    
    @Test("Check minimum level biometry touchID is false")
    func checkMinimumLevelTouchIDFalse() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = true
        #expect(try !sut.checkMinimumLevel(.biometry(type: .touchID)))
    }
    
    @Test("Check minimum level passcode is true")
    func checkMinimumLevelPasscodeTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = true
        #expect(try sut.checkMinimumLevel(.passcodeOnly))
    }
    
    @Test("Check minimum level passcode is false")
    func checkMinimumLevelPasscodeFalse() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = false
        #expect(try !sut.checkMinimumLevel(.passcodeOnly))
    }
    
    @Test("Check minimum level none is true")
    func checkMinimumLevelNoneTrue() throws {
        mockLocalAuthContext.biometryPolicyOutcome = false
        mockLocalAuthContext.anyPolicyOutcome = false
        #expect(try sut.checkMinimumLevel(.none))
    }
    
    @Test("")
    func enrolLocalAuthNotFaceID() async throws {
        mockLocalAuthContext.biometryType = .touchID
        #expect(try await sut.enrolLocalAuth())
    }
    
    @Test("")
    func enrolLocalAuthAlreadyPrompted() async throws {
        mockLocalAuthContext.biometryType = .faceID
        mockAuthPromptStore.recordPrompt()
        #expect(try await sut.enrolLocalAuth())
    }
    
    @Test("")
    func enrolLocalAuthStrings() async throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        _ = try await sut.enrolLocalAuth()
        #expect(mockLocalAuthContext.localizedFallbackTitle == "test_passcodeButton")
        #expect(mockLocalAuthContext.localizedCancelTitle == "test_cancelButton")
        #expect(mockLocalAuthContext.localizedReason == "test_reason")
    }
    
    @Test("")
    func enrolLocalAuthPromptSet() async throws {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        _ = try await sut.enrolLocalAuth()
        #expect(mockAuthPromptStore.previouslyPrompted == true)
    }
    
    @Test("")
    func enrolLocalAuthCancelError() async {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        mockLocalAuthContext.errorFromEvaluatePolicy = LAError(
            _nsError: NSError(domain: "LAErrorDomain", code: LAError.userCancel.rawValue)
        )
        
        await #expect(throws: LocalAuthenticationWrapperError.cancelled) {
            try await sut.enrolLocalAuth()
        }
    }
    
    @Test("")
    func enrolLocalAuthUnknownError() async {
        mockLocalAuthContext.biometryPolicyOutcome = true
        mockLocalAuthContext.biometryType = .faceID
        mockLocalAuthContext.errorFromEvaluatePolicy = LAError(
            _nsError: NSError(
                domain: "LAErrorDomain",
                code: LAError.authenticationFailed.rawValue
            )
        )
        
        await #expect(
            throws: NSError(
                domain: "LAErrorDomain",
                code: LAError.authenticationFailed.rawValue
            )
        ) {
            try await sut.enrolLocalAuth()
        }
    }
}
