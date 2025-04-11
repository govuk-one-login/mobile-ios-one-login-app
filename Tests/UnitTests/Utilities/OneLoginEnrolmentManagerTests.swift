import Coordination
import LocalAuthenticationWrapper
@testable import OneLogin
import XCTest

final class OneLoginEnrolmentManagerTests: XCTestCase {
    private var mockLocalAuthContext: MockLocalAuthManager!
    private var mockSessionManager: MockSessionManager!
    private var mockAnalyticsService: MockAnalyticsService!
    private var coordinator: ChildCoordinator!
    private var sut: OneLoginEnrolmentManager!
    
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
        sut = OneLoginEnrolmentManager(
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

extension OneLoginEnrolmentManagerTests {
    @MainActor
    func test_saveSession_succeeds() async {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the user has given FaceID permission
        mockLocalAuthContext.userDidConsentToFaceID = true
        // WHEN saveSession is called
        sut.saveSession()
        // THEN enrolment complete notification is sent
        await fulfillment(of: [exp], timeout: 5)
    }
    
    @MainActor
    func test_saveSession_fails() {
        // GIVEN the user has given FaceID permission
        mockLocalAuthContext.userDidConsentToFaceID = true
        // GIVEN saveSession returns an uncaught error
        mockSessionManager.errorFromSaveSession = MockError.generic
        // WHEN saveSession is called
        sut.saveSession()
        waitForTruth(self.mockSessionManager.didCallSaveSession, timeout: 5)
        // THEN an error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [MockError.generic as NSError])
    }
    
    @MainActor
    func test_saveSession_promptForPermission_false() {
        // GIVEN the user has already given FaceID permission
        mockLocalAuthContext.userDidConsentToFaceID = false
        // WHEN saveSession is called
        sut.saveSession()
        waitForTruth(self.mockLocalAuthContext.didCallEnrolFaceIDIfAvailable, timeout: 5)
        // THEN no error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [])
    }
    
    @MainActor
    func test_saveSession_promptForPermission_cancelled() {
        // GIVEN promptForPermission throws a cancelled error
        mockLocalAuthContext.errorFromEnrolLocalAuth = LocalAuthenticationWrapperError.cancelled
        // WHEN saveSession is called
        sut.saveSession()
        waitForTruth(self.mockLocalAuthContext.didCallEnrolFaceIDIfAvailable, timeout: 5)
        // THEN no error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [])
    }
    
    @MainActor
    func test_saveSession_promptForPermission_fails() {
        // GIVEN promptForPermission throws an uncaught error
        mockLocalAuthContext.errorFromEnrolLocalAuth = MockError.generic
        // WHEN saveSession is called
        sut.saveSession()
        waitForTruth(self.mockLocalAuthContext.didCallEnrolFaceIDIfAvailable, timeout: 5)
        // THEN an error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [MockError.generic as NSError])
    }
}
