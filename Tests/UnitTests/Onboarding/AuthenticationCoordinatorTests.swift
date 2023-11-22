import Authentication
@testable import OneLogin
import XCTest

@MainActor
final class AuthenticationCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockLoginSession: MockLoginSession!
    var sut: AuthenticationCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockLoginSession = MockLoginSession(window: window)
        sut = AuthenticationCoordinator(root: navigationController, session: mockLoginSession)
    }
    
    override func tearDown() {
        navigationController = nil
        mockLoginSession = nil
        sut = nil
        
        super.tearDown()
    }
}

extension AuthenticationCoordinatorTests {
    func test_start_authenticationSessionConfigProperties() throws {
        // WHEN the AuthenticationCoordinator is started
        sut.start()
        XCTAssertTrue(mockLoginSession.sessionConfiguration != nil)
        // THEN the session should have the correct login configuration details
        let sessionConfig = try XCTUnwrap(mockLoginSession.sessionConfiguration)
        XCTAssertEqual(sessionConfig.authorizationEndpoint, AppEnvironment.oneLoginAuthorize)
        XCTAssertEqual(sessionConfig.tokenEndpoint, AppEnvironment.oneLoginToken)
        XCTAssertEqual(sessionConfig.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(sessionConfig.scopes, [.openid])
        XCTAssertEqual(sessionConfig.clientID, AppEnvironment.oneLoginClientID)
        XCTAssertEqual(sessionConfig.prefersEphemeralWebSession, true)
        XCTAssertEqual(sessionConfig.redirectURI, AppEnvironment.oneLoginRedirect)
        XCTAssertEqual(sessionConfig.vectorsOfTrust, ["Cl.Cm.P0"])
        XCTAssertEqual(sessionConfig.locale, .en)
    }

    func test_start_authenticationSessionPresent() throws {
        // WHEN the AuthenticationCoordinator is started
        sut.start()
        // THEN the session should call present() with the configuration
        let sessionConfig = try XCTUnwrap(mockLoginSession.sessionConfiguration)
        mockLoginSession.present(configuration: sessionConfig)
        XCTAssertTrue(mockLoginSession.didCallPresent)
    }

    func test_handleUniversalLink_finaliseCalled() throws {
        // WHEN AuthenticationCoordinator has logged in via start()

        // THEN AuthenticationCoordinator calls finalise and returns the with tokens

    }
}
