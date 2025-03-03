import Authentication
import GDSAnalytics
@testable import OneLogin
import XCTest

final class AuthenticationServiceTests: XCTestCase {
    var window: UIWindow!
    var mockSessionManager: MockSessionManager!
    var mockLoginSession: MockLoginSession!
    var mockAnalyticsService: MockAnalyticsService!
    var sut: AuthenticationService!

    @MainActor
    override func setUp() {
        super.setUp()

        window = .init()
        mockSessionManager = MockSessionManager()
        mockLoginSession = MockLoginSession(window: window)
        mockAnalyticsService = MockAnalyticsService()
        sut = WebAuthenticationService(sessionManager: mockSessionManager,
                                       session: mockLoginSession,
                                       analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        window = nil
        mockSessionManager = nil
        mockLoginSession = nil
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension AuthenticationServiceTests {
    func test_loginError_userCancelled() async {
        mockSessionManager.errorFromStartSession = LoginError.userCancelled
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == .userCancelled)
        }
        let userCancelledEvent = ButtonEvent(textKey: "back")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [userCancelledEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], userCancelledEvent.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], userCancelledEvent.parameters["type"])
    }
    
    func test_loginError_accessDenied() async {
        mockSessionManager.errorFromStartSession = LoginError.accessDenied
        do {
            try await sut.startWebSession()
        } catch {
            guard let error = error as? LoginError else {
                XCTFail("Error should be a LoginError")
                return
            }
            XCTAssertTrue(error == .accessDenied)
        }
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    @MainActor
    func test_handleUniversalLink_catchAllError() throws {
        mockLoginSession.errorFromFinalise = AuthenticationError.generic
        do {
            let callbackURL = try XCTUnwrap(URL(string: "https://www.test.com"))
            try sut.handleUniversalLink(callbackURL)
            XCTFail("Method should throw an AuthenticationError.generic error")
        } catch let error as AuthenticationError {
            XCTAssertTrue(error == .generic)
        }
    }
}
