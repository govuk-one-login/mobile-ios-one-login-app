import Authentication
import GDSCommon
@testable import OneLogin
import XCTest

final class EnrolmentCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockLocalAuthManager: MockLocalAuthManager!
    var sut: EnrolmentCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()

        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockLocalAuthManager = MockLocalAuthManager()
        sut = EnrolmentCoordinator(root: navigationController,
                                   analyticsService: mockAnalyticsService,
                                   sessionManager: mockSessionManager,
                                   localAuthManager: mockLocalAuthManager)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockLocalAuthManager = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum SecureStoreError: Error {
        case generic
    }
}

extension EnrolmentCoordinatorTests {
    @MainActor
    func test_start_noDeviceLocalAuthSet() throws {
        // GIVEN the local authentication is enabled on the device
        mockLocalAuthManager.returnedFromCanUseLocalAuthForAuthentication = false
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
        mockLocalAuthManager.returnedFromCanUseLocalAuthForAuthentication = true
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
        mockLocalAuthManager.returnedFromCanUseLocalAuthForAuthentication = true
        // GIVEN the secure store returns an error from saving an item
        mockSessionManager.errorFromResumeSession = SecureStoreError.generic
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
        mockLocalAuthManager.returnedFromCanUseLocalAuthForBiometrics = true
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
        mockLocalAuthManager.returnedFromCanUseLocalAuthForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is face id
        mockLocalAuthManager.biometryType = .faceID
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
        mockLocalAuthManager.returnedFromCanUseLocalAuthForBiometrics = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is optic id
        if #available(iOS 17.0, *) {
            mockLocalAuthManager.biometryType = .opticID
        }
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the no screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 0)
    }
}
