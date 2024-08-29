import LocalAuthentication
@testable import OneLogin
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
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = false
        mockLAContext.biometryType = .none
        // AND a passcode is set on the device
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        // then the type is touch ID
        XCTAssertEqual(sut.type, .passcodeOnly)
    }

    func test_biometryType_noPasscode() {
        // GIVEN the device has no biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = false
        mockLAContext.biometryType = .none
        // AND a passcode is set on the device
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
        // then the type is touch ID
        XCTAssertEqual(sut.type, .none)
    }

    func test_biometryType_touchID() {
        // if the device has biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // and the biometric type is touch id
        mockLAContext.biometryType = .touchID
        // then the type is touch ID
        XCTAssertEqual(sut.type, .touchID)
    }

    func test_biometryType_faceID() {
        // if the device has biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // and the biometric type is Face ID
        mockLAContext.biometryType = .faceID
        // then the type is Face ID
        XCTAssertEqual(sut.type, .faceID)
    }

    @available(iOS 17, *)
    func test_biometryType_opticID_withPasscode() {
        // if the device has biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // and a passcode is set
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        // and the biometric type is Optic ID
        mockLAContext.biometryType = .opticID
        // then the type is Face ID
        XCTAssertEqual(sut.type, .passcodeOnly)
    }

    @available(iOS 17, *)
    func test_biometryType_opticID_withoutPasscode() {
        // if the device has biometrics
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // and a passcode is set
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
        // and the biometric type is Optic ID
        mockLAContext.biometryType = .opticID
        // then the type is Face ID
        XCTAssertEqual(sut.type, .none)
    }

    func test_canUseLocalAuth_usesLAContext() {
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        XCTAssertTrue(sut.canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics))

        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = false
        XCTAssertFalse(sut.canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics))

        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        XCTAssertTrue(sut.canUseLocalAuth(type: .deviceOwnerAuthentication))

        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
        XCTAssertFalse(sut.canUseLocalAuth(type: .deviceOwnerAuthentication))
    }
    
    func test_enrolLocalAuth_providesLocalisedStrings() async throws {
        _ = try await sut.enrolLocalAuth(reason: "any")
        XCTAssertEqual(mockLAContext.localizedFallbackTitle, "Enter passcode")
        XCTAssertEqual(mockLAContext.localizedCancelTitle, "Cancel")
    }

    func test_enrolLocalAuth_callsEvaluatePolicyForAuthentication() async throws {
        mockLAContext.returnedFromEvaluatePolicy = false
        var isEnrolled = try await sut.enrolLocalAuth(reason: "any")
        XCTAssertFalse(isEnrolled)

        mockLAContext.returnedFromEvaluatePolicy = true
        isEnrolled = try await sut.enrolLocalAuth(reason: "any")
        XCTAssertTrue(isEnrolled)

    }
}
