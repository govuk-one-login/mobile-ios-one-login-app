@testable import Authentication
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
    func test_createIntroViewController() throws {
        let introView = sut.createIntroViewController(analyticsService: mockAnalyticsService, session: mockLoginSession)
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(mockLoginSession.sessionConfiguration != nil)
    }
    
    func test_sessionConfigProperties() throws {
        let introView = sut.createIntroViewController(analyticsService: mockAnalyticsService, session: mockLoginSession)
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        let sessionConfig = try XCTUnwrap(mockLoginSession.sessionConfiguration)
        XCTAssertEqual(sessionConfig.authorizationEndpoint, URL.oneLoginAuthorize)
        XCTAssertEqual(sessionConfig.tokenEndpoint, URL.oneLoginToken)
        XCTAssertEqual(sessionConfig.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(sessionConfig.scopes, [.openid, .offline_access])
        XCTAssertEqual(sessionConfig.clientID, String.oneLoginClientID)
        XCTAssertEqual(sessionConfig.prefersEphemeralWebSession, true)
        XCTAssertEqual(sessionConfig.redirectURI, String.oneLoginRedirect)
        XCTAssertEqual(sessionConfig.viewThroughRate, "[Cl.Cm.P0]")
        XCTAssertEqual(sessionConfig.locale, .en)
    }
}
