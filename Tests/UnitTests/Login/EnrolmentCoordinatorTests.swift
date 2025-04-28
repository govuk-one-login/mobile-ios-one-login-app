import GDSCommon
import LocalAuthenticationWrapper
@testable import OneLogin
import SecureStore
import XCTest

final class EnrolmentCoordinatorTests: XCTestCase {
    private var navigationController: UINavigationController!
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockSessionManager: MockSessionManager!
    private var mockLocalAuthManager: MockLocalAuthManager!
    private var sut: EnrolmentCoordinator!
    
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
                                   sessionManager: mockSessionManager,
                                   localAuthContext: mockLocalAuthManager)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        sut = nil
        
        super.tearDown()
    }
    
    enum MockError: Error {
        case generic
    }
}

extension EnrolmentCoordinatorTests {
    @MainActor
    func test_start_deviceLocalAuthSet_none() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the local authentication's biometry type is optic id
        mockLocalAuthManager.type = .none
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the enrolment complete notification is fired
        await fulfillment(of: [exp], timeout: 5)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_passcodeOnly() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the local authentication's biometry type is passcode
        mockLocalAuthManager.type = .passcode
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the enrolment complete notification is fired
        await fulfillment(of: [exp], timeout: 5)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_touchID() throws {
        // GIVEN the local authentication's biometry type is passcode
        mockLocalAuthManager.type = .touchID
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'touch id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is BiometricsEnrolmentViewModel)
    }
    
    @MainActor
    func test_start_deviceLocalAuthSet_faceID() throws {
        // GIVEN the local authentication's biometry type is face id
        mockLocalAuthManager.type = .faceID
        // WHEN the EnrolmentCoordinator is started
        sut.start()
        // THEN the 'face id information' screen is shown
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSInformationViewController)
        XCTAssertTrue(vc.viewModel is BiometricsEnrolmentViewModel)
    }
}
