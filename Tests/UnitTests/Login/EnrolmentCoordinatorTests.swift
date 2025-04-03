import Authentication
import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

final class EnrolmentCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockLocalAuthManager: MockLocalAuthManager!
    var sut: EnrolmentCoordinator!
    
    @MainActor
    override func setUpWithError() throws {
        super.setUp()

        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()

        mockLocalAuthManager = try XCTUnwrap(
            mockSessionManager.localAuthentication as? MockLocalAuthManager
        )

        sut = EnrolmentCoordinator(root: navigationController,
                                   analyticsService: mockAnalyticsService,
                                   sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockLocalAuthManager = nil
        sut = nil
        
        super.tearDown()
    }
}

extension EnrolmentCoordinatorTests {
    @MainActor
    func test_start_deviceLocalAuthSet_none() throws {
        // GIVEN the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is optic id
        mockLocalAuthManager.type = .none
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the no additional screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 0)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_passcodeOnly() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLocalAuthManager.LABiometricsIsEnabledOnTheDevice = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is optic id
        mockLocalAuthManager.type = .passcodeOnly
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the no screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 0)
        waitForTruth(self.mockSessionManager.didCallSaveSession, timeout: 5)
    }
    
    @MainActor
    func test_secureStoreError_passcodeOnly() throws {
        // Set save session error
        mockSessionManager.errorFromSaveSession = SecureStoreError.cantDecryptData
        // GIVEN the biometric authentication is enabled on the device
        mockLocalAuthManager.LABiometricsIsEnabledOnTheDevice = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is optic id
        mockLocalAuthManager.type = .passcodeOnly
        
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the no screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 0)
        XCTAssertNotNil(mockAnalyticsService.crashesLogged)
        waitForTruth(self.mockSessionManager.didCallSaveSession, timeout: 5)
    }

    @MainActor
    func test_start_deviceLocalAuthSet_touchID() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLocalAuthManager.LABiometricsIsEnabledOnTheDevice = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'touch id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is TouchIDEnrolmentViewModel)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_faceID() throws {
        // GIVEN the biometric authentication is enabled on the device
        mockLocalAuthManager.LABiometricsIsEnabledOnTheDevice = true
        // AND the user has a valid session
        try mockSessionManager.setupSession()
        // GIVEN the local authentication's biometry type is face id
        mockLocalAuthManager.type = .faceID
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'face id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is FaceIDEnrolmentViewModel)
    }
}
