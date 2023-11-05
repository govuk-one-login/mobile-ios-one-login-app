import Authentication
@testable import OneLogin
import XCTest

final class OnboardingViewControllerFactoryTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockLoginSession: MockLoginSession!
    var sut: OnboardingViewControllerFactory.Type!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockLoginSession = MockLoginSession(window: UIWindow())
        sut = OnboardingViewControllerFactory.self
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockLoginSession = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingViewControllerFactoryTests {
    func test_introViewControllerSessionConfigProperties() throws {
        let introView = sut.createIntroViewController(analyticsService: mockAnalyticsService, session: mockLoginSession)
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(mockLoginSession.sessionConfiguration != nil)
        let sessionConfig = try XCTUnwrap(mockLoginSession.sessionConfiguration)
        XCTAssertEqual(sessionConfig.authorizationEndpoint, AppEnvironment.oneLoginAuthorize)
        XCTAssertEqual(sessionConfig.tokenEndpoint, AppEnvironment.oneLoginToken)
        XCTAssertEqual(sessionConfig.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(sessionConfig.scopes, [.openid, .offline_access])
        XCTAssertEqual(sessionConfig.clientID, AppEnvironment.oneLoginClientID)
        XCTAssertEqual(sessionConfig.prefersEphemeralWebSession, true)
        XCTAssertEqual(sessionConfig.redirectURI, AppEnvironment.oneLoginRedirect)
        XCTAssertEqual(sessionConfig.viewThroughRate, "[Cl.Cm.P0]")
        XCTAssertEqual(sessionConfig.locale, .en)
    }
}
