import LocalAuthentication
@testable import OneLogin
@testable import SecureStore
import XCTest

final class LALocalAuthenticationManagerTests: XCTestCase {
    var mockLAContext: MockLAContext!
    var sut: LALocalAuthenticationManager!

    override func setUp() {
        super.setUp()
        
        mockLAContext = MockLAContext()
        sut = LALocalAuthenticationManager(context: mockLAContext)
    }
    
    override func tearDown() {
        mockLAContext = nil
        sut = nil
        
        super.tearDown()
    }
}

extension LALocalAuthenticationManagerTests {
    func test_biometryType_passcodeOnly() {
        // GIVEN the device has no biometrics
        mockLAContext.biometricsIsEnabledOnTheDevice = false
        mockLAContext.biometryType = .none
        // AND a passcode is set on the device
        mockLAContext.localAuthIsEnabledOnTheDevice = true
        // then the type is touch ID
        XCTAssertEqual(sut.type, .passcodeOnly)
    }

    func test_biometryType_noPasscode() {
        // GIVEN the device has no biometrics
        mockLAContext.biometricsIsEnabledOnTheDevice = false
        mockLAContext.biometryType = .none
        // AND a passcode is set on the device
        mockLAContext.localAuthIsEnabledOnTheDevice = false
        // then the type is touch ID
        XCTAssertEqual(sut.type, .none)
    }

    func test_biometryType_touchID() {
        // if the device has biometrics
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        // and the biometric type is touch id
        mockLAContext.biometryType = .touchID
        // then the type is touch ID
        XCTAssertEqual(sut.type, .touchID)
    }

    func test_biometryType_faceID() {
        // if the device has biometrics
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        // and the biometric type is Face ID
        mockLAContext.biometryType = .faceID
        // then the type is Face ID
        XCTAssertEqual(sut.type, .faceID)
    }

    @available(iOS 17, *)
    func test_biometryType_opticID_withPasscode() {
        // if the device has biometrics
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        // and a passcode is set
        mockLAContext.localAuthIsEnabledOnTheDevice = true
        // and the biometric type is Optic ID
        mockLAContext.biometryType = .opticID
        // then the type is Face ID
        XCTAssertEqual(sut.type, .passcodeOnly)
    }

    @available(iOS 17, *)
    func test_biometryType_opticID_withoutPasscode() {
        // if the device has biometrics
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        // and a passcode is set
        mockLAContext.localAuthIsEnabledOnTheDevice = false
        // and the biometric type is Optic ID
        mockLAContext.biometryType = .opticID
        // then the type is Face ID
        XCTAssertEqual(sut.type, .none)
    }

    func test_contextStrings_correctForFaceID() throws {
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        mockLAContext.biometryType = .faceID

        let strings = try XCTUnwrap(mockLAContext.contextStrings)

        XCTAssertEqual(strings.localizedReason, "Enter iPhone passcode")
        XCTAssertEqual(strings.localisedFallbackTitle, "Enter passcode")
        XCTAssertEqual(strings.localisedCancelTitle, "Cancel")
    }

    func test_contextStrings_correctForTouchID() throws {
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        mockLAContext.biometryType = .touchID

        let strings = try XCTUnwrap(mockLAContext.contextStrings)
       
        XCTAssertEqual(strings.localizedReason, "Unlock to proceed")
        XCTAssertEqual(strings.localisedFallbackTitle, "Enter passcode")
        XCTAssertEqual(strings.localisedCancelTitle, "Cancel")
    }

    func test_contextStrings_nilForNone() throws {
        mockLAContext.biometryType = .none
        XCTAssertNil(mockLAContext.contextStrings)
    }

    func test_canUseLocalAuth_usesLAContext() {
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        XCTAssertTrue(sut.canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics))

        mockLAContext.biometricsIsEnabledOnTheDevice = false
        XCTAssertFalse(sut.canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics))

        mockLAContext.localAuthIsEnabledOnTheDevice = true
        XCTAssertTrue(sut.canUseLocalAuth(type: .deviceOwnerAuthentication))

        mockLAContext.localAuthIsEnabledOnTheDevice = false
        XCTAssertFalse(sut.canUseLocalAuth(type: .deviceOwnerAuthentication))
    }
    
    func test_enrolLocalAuth_providesLocalisedStrings() async throws {
        // GIVEN FaceID is enabled on the device
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        mockLAContext.biometryType = .faceID
        // WHEN I try to enrol FaceID
        _ = try await sut.enrolFaceIDIfAvailable()
        // THEN the context strings are set correctly
        XCTAssertEqual(mockLAContext.localizedFallbackTitle, "Enter passcode")
        XCTAssertEqual(mockLAContext.localizedCancelTitle, "Cancel")
    }
    
    func test_enrolFaceIDIfRequired_returnsTrueIfUserConsents() async throws {
        // GIVEN FaceID is enabled on the device
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        mockLAContext.biometryType = .faceID
        // WHEN I try to enrol FaceID
        mockLAContext.userConsentedToBiometrics = true
        let isEnroled = try await sut.enrolFaceIDIfAvailable()
        // THEN the user has been asked for consent
        XCTAssertTrue(mockLAContext.didCallEvaluatePolicy)
        // THEN enrolment is successful
        XCTAssertTrue(isEnroled)
    }

    func test_enrolFaceIDIfRequired_returnsFalseIfUserDeclinesConsent() async throws {
        // GIVEN FaceID is enabled on the device
        mockLAContext.biometricsIsEnabledOnTheDevice = true
        mockLAContext.biometryType = .faceID
        // WHEN I try to enrol FaceID
        mockLAContext.userConsentedToBiometrics = false
        let isEnroled = try await sut.enrolFaceIDIfAvailable()
        // THEN the user has been asked for consent
        XCTAssertTrue(mockLAContext.didCallEvaluatePolicy)
        // THEN enrolment is not successful
        XCTAssertFalse(isEnroled)
    }
    
    func test_enrolFaceIDIfRequired_returnsTrueIfFaceIDUnavailable() async throws {
        // GIVEN the biometrics are disabled on the device
        mockLAContext.biometricsIsEnabledOnTheDevice = false
        mockLAContext.biometryType = .none
        // WHEN I try to enrol FaceID
        mockLAContext.userConsentedToBiometrics = false
        let isEnroled = try await sut.enrolFaceIDIfAvailable()
        // THEN the user has not been asked for consent
        XCTAssertFalse(mockLAContext.didCallEvaluatePolicy)
        // THEN enrolment is successful
        XCTAssertTrue(isEnroled)
    }
}
