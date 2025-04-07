import Coordination
import LocalAuthenticationWrapper
@testable import OneLogin
import XCTest

final class OneLoginLocalAuthManagerTests: XCTestCase {
    private var mockLocalAuthContext: MockLocalAuthManager!
    private var mockSessionManager: MockSessionManager!
    private var mockAnalyticsService: MockAnalyticsService!
    private var coordinator: ChildCoordinator!
    private var sut: OneLoginLocalAuthManager!
    
    @MainActor
    override func setUp() {
        mockLocalAuthContext = MockLocalAuthManager()
        mockSessionManager = MockSessionManager()
        mockAnalyticsService = MockAnalyticsService()
        coordinator = EnrolmentCoordinator(
            root: UINavigationController(),
            analyticsService: mockAnalyticsService,
            sessionManager: mockSessionManager
        )
        sut = OneLoginLocalAuthManager(
            localAuthContext: mockLocalAuthContext,
            sessionManager: mockSessionManager,
            analyticsService: mockAnalyticsService,
            coordinator: coordinator
        )
    }
    
    override func tearDown() {
        mockLocalAuthContext = nil
        mockSessionManager = nil
        mockAnalyticsService = nil
        coordinator = nil
        sut = nil
    }
    
    enum MockError: Error {
        case generic
    }
}

extension OneLoginLocalAuthManagerTests {
    @MainActor
    func test_saveSession_succeeds() async {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        mockLocalAuthContext.userDidConsentToFaceID = true
        sut.saveSession()
        await fulfillment(of: [exp], timeout: 5)
    }
    
    @MainActor
    func test_saveSession_fails() {
        mockLocalAuthContext.userDidConsentToFaceID = true
        mockSessionManager.errorFromSaveSession = MockError.generic
        sut.saveSession()
        waitForTruth(self.mockSessionManager.didCallSaveSession, timeout: 5)
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [MockError.generic as NSError])
    }
    
    @MainActor
    func test_saveSession_promptForPermission_false() {
        mockLocalAuthContext.userDidConsentToFaceID = false
        sut.saveSession()
        waitForTruth(self.mockLocalAuthContext.didCallEnrolFaceIDIfAvailable, timeout: 5)
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [])
    }
    
    @MainActor
    func test_saveSession_promptForPermission_fails() {
        mockLocalAuthContext.errorFromEnrolLocalAuth = MockError.generic
        sut.saveSession()
        waitForTruth(self.mockLocalAuthContext.didCallEnrolFaceIDIfAvailable, timeout: 5)
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [MockError.generic as NSError])
    }
    
    @MainActor
    func test_saveSession_promptForPermission_cancelled() {
        mockLocalAuthContext.errorFromEnrolLocalAuth = LocalAuthenticationWrapperError.cancelled
        sut.saveSession()
        waitForTruth(self.mockLocalAuthContext.didCallEnrolFaceIDIfAvailable, timeout: 5)
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [])
    }
}
