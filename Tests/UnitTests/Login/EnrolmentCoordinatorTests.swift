import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

final class EnrolmentCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockLAContext: MockLAContext!
    var sut: EnrolmentCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()

        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockLAContext = MockLAContext()
        sut = EnrolmentCoordinator(root: navigationController,
                                   analyticsService: mockAnalyticsService,
                                   sessionManager: mockSessionManager,
                                   localAuth: mockLAContext)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockLAContext = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum LocalAuthError: Error {
        case generic
    }
    
    private enum SecureStoreError: Error {
        case generic
    }
}

extension EnrolmentCoordinatorTests {
    @MainActor
    func test_start_noDeviceLocalAuthSet() throws {
        // GIVEN the local authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = false
        // AND the user is logged in
        mockSessionManager.user = MockUser()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'passcode information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is PasscodeInformationViewModel)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_passcode_succeeds() throws {
        // GIVEN the local authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        // AND there is a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the journey should be saved in user defaults
        // TODO: what is the expected effect?
        // sessionManager.something is called
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_passcode_fails() throws {
        // GIVEN the local authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForAuthentication = true
        // GIVEN the secure store returns an error from saving an item
        mockSessionManager.shouldThrowResumeError = SecureStoreError.generic
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the journey should be saved in user defaults
        // TODO: what is the expected effect here?
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_touchID() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'touch id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is TouchIDEnrollmentViewModel)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_faceID() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is face id
        mockLAContext.biometryType = .faceID
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'face id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is FaceIDEnrollmentViewModel)
    }

    @MainActor
    func test_start_deviceLocalAuthSet_opticID() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is optic id
        if #available(iOS 17.0, *) {
            mockLAContext.biometryType = .opticID
        }
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the no screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 0)
    }
    
    func test_enrolLocalAuth_succeeds() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator's enrolLocalAuth method is called
        Task { await sut.enrolLocalAuth(reason: "") }
        // THEN the journey should be saved in user defaults
        // TODO: what is the expected effect here?
        XCTAssertEqual(mockLAContext.localizedFallbackTitle, "Enter passcode")
        XCTAssertEqual(mockLAContext.localizedCancelTitle, "Cancel")
    }
    
    func test_enrolLocalAuth_fails() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator's enrolLocalAuth method is called
        Task { await sut.enrolLocalAuth(reason: "") }
        // THEN the journey should be saved in user defaults
        // TODO: what is the expected effect here?
    }
    
    func test_enrolLocalAuth_errors() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator's enrolLocalAuth method is called
        Task { await sut.enrolLocalAuth(reason: "") }
        // THEN the journey should be saved in user defaults
        // TODO: what is the expected effect here?
    }
}
